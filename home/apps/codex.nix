{ config, inputs, lib, osConfig, pkgs, ... }:
let
  agents = inputs.llm-agents.packages.${pkgs.stdenv.hostPlatform.system};
  defaultMathNotesRoot = "${config.home.homeDirectory}/code/tyle";
  mathPresetHomePath = "${config.home.homeDirectory}/.dsh/.agent-presets/math-notes";
  engramDataDirectory = "${config.home.homeDirectory}/.engram";
  openAIAPIKeyPath = osConfig.sops.secrets.openai_api_key.path;

  fullPresetWebFragment = pkgs.writeText "dsh-full-preset-web.yml" ''
    # API-key-free web search and bounded page extraction.  The stock tool-web
    # plugin requires the host-level DeepSeek web provider, which this deployment
    # deliberately disables in favour of the configured OpenAI-compatible model.
    - id: mcp-duckduckgo
      name: '@deepseek-ai/dsh-mcp-client'
      config:
        serverName: duckduckgo
        transport: stdio
        command: '${pkgs.uv}/bin/uvx'
        args:
          - --from
          - 'duckduckgo-mcp-server[browser]==0.6.1'
          - duckduckgo-mcp-server
          - --fetch-backend
          - auto
        env:
          DDG_REGION: wt-wt
          DDG_SAFE_SEARCH: MODERATE
          UV_PYTHON: '${lib.getExe pkgs.python3}'
          UV_PYTHON_DOWNLOADS: never
          UV_NO_MANAGED_PYTHON: '1'
          UV_ISOLATED: '1'
        toolCallTimeoutMs: 120000
  '';

  # The shipped full presets expect the DeepSeek-backed host web service.
  # Patch them in place so every built-in mode remains selectable while using
  # the shared OpenAI-compatible GPT route and key-free DuckDuckGo MCP backend.
  dshPackage = agents.dsh.overrideAttrs (old: {
    nativeBuildInputs = (old.nativeBuildInputs or [ ]) ++ [ pkgs.patch ];
    postInstall = (old.postInstall or "") + ''
      session_manager_dir="$out/lib/node_modules/@deepseek-ai/dsh/node_modules/@raca/dsh-session-manager"
      mkdir -p "$session_manager_dir"
      cp -R ${./dsh/session-manager-plugin}/. "$session_manager_dir/"
      test -f "$session_manager_dir/lib/index.js"
      test -f "$session_manager_dir/lib/client.js"

      math_compaction_dir="$out/lib/node_modules/@deepseek-ai/dsh/node_modules/@raca/dsh-math-compaction"
      mkdir -p "$(dirname "$math_compaction_dir")"
      cp -R "$out/lib/node_modules/@deepseek-ai/dsh/node_modules/@deepseek-ai/dsh-compaction-basic" "$math_compaction_dir"
      chmod -R u+w "$math_compaction_dir"
      sed -i 's/"name": "@deepseek-ai\/dsh-compaction-basic"/"name": "@raca\/dsh-math-compaction"/' "$math_compaction_dir/package.json"
      patch --fuzz=0 -d "$math_compaction_dir" -p1 < ${./dsh/math-compaction.patch}
      test "$(grep -c '## Definitions and Notation' "$math_compaction_dir/lib/index.js")" -eq 1
      test "$(grep -c 'mathematical study conversation' "$math_compaction_dir/lib/index.js")" -eq 1

      for preset in standard code cordis; do
        preset_dir="$out/lib/node_modules/@deepseek-ai/dsh/config/agent-presets/$preset"
        sed -i \
          -e '/^# The `web` service and its search provider stay in the host composition; only$/r ${fullPresetWebFragment}' \
          -e '/^# The `web` service and its search provider stay in the host composition; only$/,/^    searchTimeoutMs: 60000$/d' \
          "$preset_dir/agent.cordis.yml"
        # Recomposition mounts the replacement before disposing the current preset.
        # MCP server names are process-global, so every preset needs its own name.
        sed -i \
          "s/^    serverName: duckduckgo$/    serverName: duckduckgo-$preset/" \
          "$preset_dir/agent.cordis.yml"
        test "$(grep -c '@deepseek-ai/dsh-tool-web' "$preset_dir/agent.cordis.yml")" -eq 0
        test "$(grep -c 'UV_NO_MANAGED_PYTHON' "$preset_dir/agent.cordis.yml")" -eq 1
        test "$(grep -c "serverName: duckduckgo-$preset" "$preset_dir/agent.cordis.yml")" -eq 1
      done
    '';
  });

  engram = pkgs.stdenvNoCC.mkDerivation {
    pname = "engram";
    version = "1.20.0";

    src = pkgs.fetchurl {
      url = "https://github.com/Gentleman-Programming/engram/releases/download/v1.20.0/engram_1.20.0_linux_amd64.tar.gz";
      hash = "sha256-fcMAMxjjA77iaaR3IUTzzgHI7HAL/VJKrsdncKzTico=";
    };

    sourceRoot = ".";
    installPhase = ''
      runHook preInstall
      install -Dm755 engram "$out/bin/engram"
      runHook postInstall
    '';

    meta = {
      description = "Persistent memory system for AI coding agents";
      homepage = "https://github.com/Gentleman-Programming/engram";
      license = lib.licenses.mit;
      mainProgram = "engram";
      platforms = [ "x86_64-linux" ];
    };
  };

  dshConfigPatch = pkgs.writeText "dsh-config.patch.yml" ''
    - id: agent-default-model
      config:
        provider: openai
        model: gpt-5.6-sol

    - id: llm-pi-ai
      config:
        providers:
          openai:
            apiKeyEnv: OPENAI_API_KEY
            baseURL: https://api.plos.edu.ci/v1
            reasoning: high
            models:
              - id: gpt-5.4
                contextWindow: 272000
              - id: gpt-5.5
                contextWindow: 272000
              - id: gpt-5.6-luna
                contextWindow: 272000
              - id: gpt-5.6-sol
                contextWindow: 272000
              - id: gpt-5.6-terra
                contextWindow: 272000

          # A separate route keeps compaction from inheriting the main agent's
          # high-reasoning default, which can consume the whole summary budget.
          openai-compact:
            apiKeyEnv: OPENAI_API_KEY
            api: openai-responses
            baseURL: https://api.plos.edu.ci/v1
            defaultInput: [text, image]
            models:
              - id: gpt-5.6-luna
                contextWindow: 272000
                maxTokens: 8192
                reasoningEfforts: false

    - id: llm-deepseek
      disabled: true

    - id: web
      disabled: true

    - id: web-search-deepseek
      disabled: true

    # The headless profile enables this host-level consumer independently of
    # the agent preset.  Disable it together with the web service or the whole
    # plugin tree remains pending while waiting for the absent `web` service.
    - id: tool-web
      disabled: true

    - id: agent-presets
      config:
        default: math-notes

    # Local dual-face Web plugin: a Settings page for archive/restore/delete,
    # plus a small current-session archive action in the conversation header.
    - insert:
        - id: session-manager
          name: '@raca/dsh-session-manager'
          config:
            trashRoot: !!js dshHomePath('session-trash')
            pendingPath: !!js dshHomePath('session-manager/pending-delete.json')
  '';

  dshWrapped = pkgs.writeShellApplication {
    name = "dsh";
    text = ''
      unset DPSK_API_KEY DEEPSEEK_API_KEY
      if [[ ''${1-} == plugin ]]; then
        exec ${lib.getExe dshPackage} "$@"
      fi
      if [[ -z ''${OPENAI_API_KEY:-} ]]; then
        openai_api_key_file=${lib.escapeShellArg openAIAPIKeyPath}
        if [[ ! -r "$openai_api_key_file" ]]; then
          echo "dsh: OPENAI_API_KEY is unset and $openai_api_key_file is not readable" >&2
          exit 1
        fi
        OPENAI_API_KEY="$(<"$openai_api_key_file")"
        if [[ -z "$OPENAI_API_KEY" ]]; then
          echo "dsh: $openai_api_key_file is empty" >&2
          exit 1
        fi
        export OPENAI_API_KEY
      fi
      if (( $# == 0 )); then
        set -- --profile web
      fi
      exec ${lib.getExe dshPackage} --patch ${dshConfigPatch} "$@"
    '';
  };

  dshApp = pkgs.writeShellApplication {
    name = "deepseek-harness";
    runtimeInputs = [
      pkgs.coreutils
      pkgs.curl
      pkgs.gnugrep
      pkgs.gnused
      pkgs.libnotify
      pkgs.chromium
    ];
    text = ''
      default_notes_root=${lib.escapeShellArg defaultMathNotesRoot}
      workspace=""

      usage() {
        cat <<'EOF'
      Usage: deepseek-harness [--workspace PATH | PATH]

      Workspace selection order:
        1. command-line PATH
        2. DSH_WORKSPACE or DSH_CWD
        3. current directory when it looks like a project
        4. the default mathematical notes directory, when present
        5. current directory
      EOF
      }

      if (( $# > 0 )); then
        case "$1" in
          -h|--help)
            usage
            exit 0
            ;;
          --workspace)
            if (( $# < 2 )); then
              echo "deepseek-harness: --workspace requires a path" >&2
              exit 2
            fi
            workspace="$2"
            shift 2
            ;;
          --workspace=*)
            workspace="''${1#--workspace=}"
            shift
            ;;
          --*)
            echo "deepseek-harness: unknown option: $1" >&2
            usage >&2
            exit 2
            ;;
          *)
            workspace="$1"
            shift
            ;;
        esac
      fi
      if (( $# > 0 )); then
        echo "deepseek-harness: unexpected argument: $1" >&2
        usage >&2
        exit 2
      fi

      if [[ -z "$workspace" ]]; then
        workspace="''${DSH_WORKSPACE:-''${DSH_CWD:-}}"
      fi

      if [[ -z "$workspace" ]]; then
        current_workspace="$PWD"
        if [[ -e "$current_workspace/.git" \
          || -d "$current_workspace/.dsh" \
          || -f "$current_workspace/typst.toml" \
          || -f "$current_workspace/lakefile.toml" \
          || -f "$current_workspace/lakefile.lean" \
          || -f "$current_workspace/lean-toolchain" \
          || -f "$current_workspace/flake.nix" ]] \
          || compgen -G "$current_workspace/*.typ" >/dev/null \
          || compgen -G "$current_workspace/*.lean" >/dev/null; then
          workspace="$current_workspace"
        elif [[ -d "$default_notes_root" ]]; then
          workspace="$default_notes_root"
        else
          workspace="$current_workspace"
        fi
      fi

      if [[ ! -d "$workspace" ]]; then
        echo "DeepSeek Harness: workspace does not exist or is not a directory: $workspace" >&2
        exit 1
      fi
      workspace="$(realpath -- "$workspace")"
      export DSH_CWD="$workspace"
      cd "$workspace"

      runtime_parent="''${XDG_RUNTIME_DIR:-/tmp}"
      runtime_dir="$(mktemp --directory --tmpdir="$runtime_parent" deepseek-harness.XXXXXXXX)"
      log_file="$runtime_dir/server.log"
      server_pid=""

      cleanup() {
        if [[ -n "$server_pid" ]] && kill -0 "$server_pid" 2>/dev/null; then
          kill "$server_pid" 2>/dev/null || true
          wait "$server_pid" 2>/dev/null || true
        fi
        rm -r -- "$runtime_dir"
      }

      fail() {
        notify-send --app-name="DeepSeek Harness" \
          "DeepSeek Harness 启动失败" \
          "$(tail -n 12 "$log_file" 2>/dev/null || true)"
        exit 1
      }

      trap cleanup EXIT
      trap 'exit 130' INT
      trap 'exit 143' HUP TERM

      ${lib.getExe dshWrapped} --profile web \
        --host 127.0.0.1 --port 0 --no-open >"$log_file" 2>&1 &
      server_pid=$!

      harness_url=""
      for _ in $(seq 1 300); do
        if ! kill -0 "$server_pid" 2>/dev/null; then
          fail
        fi
        harness_url="$(sed -n 's/^dsh web: \(http:\/\/127\.0\.0\.1:[0-9][0-9]*\)$/\1/p' "$log_file" | tail -n 1)"
        if [[ -n "$harness_url" ]] && curl --fail --silent --show-error "$harness_url" >/dev/null; then
          break
        fi
        sleep 0.1
      done

      if [[ -z "$harness_url" ]]; then
        fail
      fi

      chromium_state="''${XDG_STATE_HOME:-$HOME/.local/state}/deepseek-harness/chromium"
      mkdir -p "$chromium_state"

      ${lib.getExe pkgs.chromium} \
        --app="$harness_url" \
        --class=DeepSeek-Harness \
        --user-data-dir="$chromium_state" \
        --no-first-run \
        --password-store=basic \
        --disable-background-networking \
        --disable-component-update \
        --disable-default-apps \
        --disable-extensions \
        --disable-sync \
        --disable-features=MediaRouter,OptimizationHints,Translate
    '';
  };

  mathPresetPatch = pkgs.replaceVars ./dsh/math-preset.patch {
    engramDataDirectory = engramDataDirectory;
    engramExecutable = lib.getExe engram;
    mathCompactionModule = "${dshPackage}/lib/node_modules/@deepseek-ai/dsh/node_modules/@raca/dsh-math-compaction/lib/index.js";
    pythonExecutable = lib.getExe pkgs.python3;
    uvxExecutable = "${pkgs.uv}/bin/uvx";
  };

  mathPreset = pkgs.runCommand "dsh-math-notes-preset" {
    nativeBuildInputs = [ pkgs.patch ];
  } ''
    mkdir -p "$out"
    cp -R ${agents.dsh}/lib/node_modules/@deepseek-ai/dsh/config/agent-presets/standard/. "$out"
    chmod -R u+w "$out"
    patch -d "$out" -p1 < ${mathPresetPatch}
    test "$(grep -c 'UV_NO_MANAGED_PYTHON' "$out/agent.cordis.yml")" -eq 2
    test "$(grep -c 'UV_ISOLATED' "$out/agent.cordis.yml")" -eq 2
    test "$(grep -c 'serverName: duckduckgo-math-notes' "$out/agent.cordis.yml")" -eq 1
    test "$(grep -c '/@raca/dsh-math-compaction/lib/index.js' "$out/agent.cordis.yml")" -eq 1
    test "$(grep -c 'failOnStartupError: true' "$out/agent.cordis.yml")" -eq 1
    test "$(grep -c 'process.env.DSH_CWD ?? process.cwd()' "$out/agent.cordis.yml")" -eq 1
    test "$(grep -c ${lib.escapeShellArg defaultMathNotesRoot} "$out/agent.cordis.yml")" -eq 0
  '';
in
{
  home.packages =
    (with agents; [
      claude-code
      codex
      gemini-cli
      opencode
    ])
    ++ [
      dshWrapped
      dshApp
      engram
      pkgs.elan
      pkgs.typst
    ];

  home.file = {
    ".dsh/.agent-presets/math-notes" = {
      source = mathPreset;
      recursive = true;
    };
    ".dsh/skills/math-study/SKILL.md".source = ./dsh/skills/math-study/SKILL.md;
    ".dsh/skills/typst-notes/SKILL.md".source = ./dsh/skills/typst-notes/SKILL.md;
    ".dsh/skills/lean-notes/SKILL.md".source = ./dsh/skills/lean-notes/SKILL.md;
  };

  xdg.dataFile."icons/hicolor/scalable/apps/deepseek-harness.svg".source =
    "${dshPackage}/lib/node_modules/@deepseek-ai/dsh/node_modules/@deepseek-ai/dsh-web-frontend/dist/favicon.svg";

  xdg.desktopEntries.deepseek-harness = {
    name = "DeepSeek Harness";
    genericName = "AI Study and Coding Workspace";
    comment = "Open an adaptive DeepSeek Harness workspace";
    exec = lib.getExe dshApp;
    icon = "deepseek-harness";
    terminal = false;
    categories = [ "Development" "Utility" ];
    startupNotify = true;
    settings.StartupWMClass = "DeepSeek-Harness";
  };

  # Migrate the old whole-directory Home Manager link before collision checks.
  # Recursive deployment needs the preset root itself to be a real directory
  # because dsh deliberately ignores symlink entries during preset discovery.
  home.activation.migrateDshMathPreset = lib.hm.dag.entryBefore [ "checkLinkTargets" ] ''
    if [[ -L ${lib.escapeShellArg mathPresetHomePath} ]]; then
      rm -- ${lib.escapeShellArg mathPresetHomePath}
    fi
  '';

  # home.file.".codex/config.toml".text = ''
  #   model_reasoning_effort = "high"
  #   model_provider = "e-flowcode"
  #   model = "gpt-5.5"
  #  
  #   [model_providers.e-flowcode]
  #   name = "e-flowcode"
  #   base_url = "https://e-flowcode.cc/v1"
  #   env_key = "E_FLOW_API_KEY"
  # '';
}
