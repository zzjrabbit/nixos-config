{ inputs, pkgs, ... }:

let
  minimal-nvim = pkgs.vimUtils.buildVimPlugin {
    pname = "minimal.nvim";
    version = "0-unstable-2024-10-29";
    src = inputs.minimal-nvim;
  };

  extraGrammars = with pkgs.vimPlugins.nvim-treesitter.grammarPlugins; [
    bash
    cpp
    css
    dockerfile
    gitignore
    html
    javascript
    json
    markdown
    nix
    python
    rust
    toml
    tsx
    typescript
    yaml
  ];

  colors = {
    base01 = "#282a2e";
    base02 = "#373b41";
    base03 = "#969896";
    base04 = "#b4b7b4";
    base05 = "#c5c8c6";
    base09 = "#de935f";
    base0B = "#b5bd68";
    base0D = "#81a2be";
    base0E = "#b294bb";
  };

  lualineTheme =
    let
      segment = fg: bg: { inherit fg bg; };
      active = { b = segment colors.base05 colors.base02; };
      inactive = segment colors.base03 colors.base01;
    in
    {
      normal = active // {
        a = segment colors.base01 colors.base0D;
        c = segment colors.base04 colors.base01;
      };
      insert = active // { a = segment colors.base01 colors.base0B; };
      visual = active // { a = segment colors.base01 colors.base0E; };
      replace = active // { a = segment colors.base01 colors.base09; };
      inactive = { a = inactive; b = inactive; c = inactive; };
    };

  nvfSettings = { lib, ... }: {
    vim.lineNumberMode = "number";
    vim.clipboard = {
      enable = true;
      registers = "unnamedplus";
      providers.wl-copy.enable = true;
    };
    vim.options = {
      cursorline = true;
      cursorlineopt = "both";
      grepprg = "${lib.getExe pkgs.ripgrep} --vimgrep --no-heading";
      redrawtime = 100;
      shiftwidth = 4;
      tabstop = 4;
    };

    vim.lsp.enable = true;

    vim.diagnostics = {
      enable = true;
      config = {
        severity_sort = true;
        virtual_text = {
          spacing = 2;
          source = "if_many";
          prefix = "●";
        };
      };
    };

    vim.languages = {
      bash.enable = true;
      clang.enable = true;
      json.enable = true;
      markdown.enable = true;
      nix = {
        enable = true;
        lsp.servers = [ "nixd" ];
        format = {
          enable = true;
          type = [ "nixfmt" ];
        };
      };
      python.enable = true;
      rust.enable = true;
      toml.enable = true;
    };

    vim.git.gitsigns = {
      enable = true;
      mappings = {
        toggleBlame = "<leader>gb";
        toggleDeleted = "<leader>gd";
      };
    };
    vim.mini.pairs.enable = true;

    vim.formatter.conform-nvim.setupOpts = {
      format_on_save = lib.mkForce null;
      format_after_save = lib.mkForce null;
    };

    vim.autocomplete.blink-cmp = {
      enable = true;
      friendly-snippets.enable = true;
      mappings.confirm = null;
      mappings.next = null;
      setupOpts = {
        keymap = {
          preset = "default";
          "<Tab>" = [ "accept" "fallback" ];
          "<CR>" = [ "fallback" ];
        };
        signature.enabled = true;
      };
    };

    vim.statusline.lualine = {
      enable = true;
      setupOpts = lib.mkForce {
        options = {
          theme = lualineTheme;
          globalstatus = true;
          always_show_tabline = false;
        };
        tabline = {
          lualine_a = [
            {
              "@1" = "tabs";
              mode = 2;
              tab_max_length = 24;
            }
          ];
        };
      };
    };

    vim.assistant.copilot.enable = true;
    vim.utility.diffview-nvim.enable = true;
    vim.binds.whichKey.enable = true;
    vim.visuals.nvim-web-devicons.enable = true;

    vim.utility.snacks-nvim = {
      enable = true;
      setupOpts = {
        explorer.enabled = true;
        picker.enabled = true;
        picker.ui_select = true;
        picker.sources.explorer.hidden = true;
        picker.sources.explorer.layout.hidden = [ "input" ];
        scroll.enabled = true;
        indent.enabled = true;
        input.enabled = true;
        notifier.enabled = true;
        terminal = {
          shell = [ (lib.getExe pkgs.nushell) ];
          win = {
            position = "float";
            backdrop = 60;
            border = "rounded";
            width = 0.88;
            height = 0.82;
            title = " 󰆍  Nushell ";
            title_pos = "center";
            wo.winhighlight = "Normal:SnacksTerminal,NormalNC:SnacksTerminal,FloatBorder:SnacksTerminalBorder,FloatTitle:SnacksTerminalTitle";
            keys.term_normal = lib.generators.mkLuaInline ''
              { "<C-]>", "<cmd>stopinsert<cr>", mode = "t", desc = "Exit terminal mode" }
            '';
          };
        };
        words.enabled = true;
        bigfile.enabled = true;
        quickfile.enabled = true;
        dashboard.sections = [
          { section = "header"; }
          { section = "keys"; gap = 1; padding = 1; }
        ];
      };
    };

    vim.session.nvim-session-manager = {
      enable = true;
      usePicker = false;
      mappings.loadSession = "<leader>wr";
      setupOpts.autoload_mode = "CurrentDir";
    };

    vim.autocmds = [
      {
        event = [ "User" ];
        pattern = [ "SessionLoadPost" ];
        command = "lua Snacks.explorer()";
        desc = "Open explorer after restoring a session";
      }
    ];

    vim.treesitter = {
      enable = true;
      grammars = extraGrammars;
    };

    vim.startPlugins = [ minimal-nvim ];
    vim.luaConfigRC.theme = lib.nvim.dag.entryBefore [ "pluginConfigs" ] ''
      vim.cmd.colorscheme("minimal-base16")
    '';

    vim.highlight = {
      SignColumn.bg = "NONE";
      CursorLine.bg = "NONE";
      LineNr = { bg = "NONE"; fg = colors.base03; };
      CursorLineNr = { bg = "NONE"; fg = colors.base05; bold = true; };
      SnacksTerminal = { bg = colors.base01; fg = colors.base05; };
      SnacksTerminalBorder = { bg = colors.base01; fg = colors.base03; };
      SnacksTerminalTitle = { bg = colors.base01; fg = colors.base0D; bold = true; };
    };

    vim.keymaps = [
      {
        mode = "n";
        key = "<F1>";
        action = "function() Snacks.picker.commands() end";
        lua = true;
        desc = "Commands";
      }
      {
        mode = "n";
        key = "<leader>,";
        action = "function() Snacks.picker.buffers() end";
        lua = true;
        desc = "Buffers";
      }
      {
        mode = "n";
        key = "<leader>e";
        action = "function() Snacks.explorer() end";
        lua = true;
        desc = "Explorer";
      }
      {
        mode = "n";
        key = "<leader>ff";
        action = "function() Snacks.picker.files() end";
        lua = true;
        desc = "Find files";
      }
      {
        mode = "n";
        key = "<leader>fs";
        action = "function() Snacks.picker.grep() end";
        lua = true;
        desc = "Grep";
      }
      {
        mode = "n";
        key = "<leader>t";
        action = "function() Snacks.terminal() end";
        lua = true;
        desc = "Toggle Nushell terminal";
      }
      {
        mode = "n";
        key = "<C-h>";
        action = "<cmd>wincmd h<cr>";
        desc = "Focus left window";
      }
      {
        mode = "n";
        key = "<C-j>";
        action = "<cmd>wincmd j<cr>";
        desc = "Focus lower window";
      }
      {
        mode = "n";
        key = "<C-k>";
        action = "<cmd>wincmd k<cr>";
        desc = "Focus upper window";
      }
      {
        mode = "n";
        key = "<C-l>";
        action = "<cmd>wincmd l<cr>";
        desc = "Focus right window";
      }
      {
        mode = "n";
        key = "]g";
        action = "function() vim.diagnostic.jump({ count = 1 }) end";
        lua = true;
        desc = "Next diagnostic";
      }
      {
        mode = "n";
        key = "[g";
        action = "function() vim.diagnostic.jump({ count = -1 }) end";
        lua = true;
        desc = "Previous diagnostic";
      }
      {
        mode = "n";
        key = "<leader>gs";
        action = "<cmd>DiffviewOpen<cr>";
        desc = "Git changes";
      }
      {
        mode = "n";
        key = "<leader>cf";
        action = "function() require(\"conform\").format({ async = true }) end";
        lua = true;
        desc = "Format";
      }
    ];
  };
in
{
  imports = [ inputs.nvf.homeManagerModules.default ];

  programs.nvf = {
    enable = true;
    settings = nvfSettings;
  };
}
