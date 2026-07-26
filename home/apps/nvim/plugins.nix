{ pkgs, palette }:

let
  inherit (palette) ui lualineState;

  # Keep file-type icons inside the same subdued semantic palette used by the
  # rest of Neovim instead of pulling in the much brighter upstream colours.
  devIcon = icon: color: name: {
    inherit icon color;
    name = "Palette${name}";
  };

  lualineTheme =
    let
      segment = fg: bg: { inherit fg bg; };
      middle = {
        b = segment ui.text ui.raised;
        c = segment ui.muted ui.surface;
      };
      mode = color: segment ui.bg color;
      inactive = segment ui.muted ui.surface;
    in
    {
      normal = middle // { a = mode lualineState.normal; };
      insert = middle // { a = mode lualineState.insert; };
      visual = middle // { a = mode lualineState.visual; };
      replace = middle // { a = mode lualineState.replace; };
      command = middle // { a = mode lualineState.command; };
      inactive = { a = inactive; b = inactive; c = inactive; };
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
  ] ++ [ pkgs.tree-sitter-grammars.tree-sitter-lean ];
in
{ lib, ... }: {
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
        component_separators = {
          left = "";
          right = "";
        };
        section_separators = {
          left = "";
          right = "";
        };
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
  vim.extraPlugins.lean-nvim = {
    package = pkgs.vimPlugins.lean-nvim;
    setup = ''
      require("lean").setup({})
    '';
  };
  vim.visuals.nvim-web-devicons = {
    enable = true;
    setupOpts = {
      color_icons = true;
      default = true;
      override = {
        default_icon = devIcon "" ui.muted "Default";
      };
      override_by_extension = {
        nix = devIcon "" ui.info "Nix";
        lua = devIcon "" ui.info "Lua";
        nu = devIcon "" ui.success "Nushell";
        sh = devIcon "" ui.success "Sh";
        bash = devIcon "" ui.success "Bash";
        zsh = devIcon "" ui.success "Zsh";
        py = devIcon "" ui.warning "Py";
        rs = devIcon "" ui.danger "Rs";
        c = devIcon "" ui.info "C";
        cpp = devIcon "" ui.info "Cpp";
        h = devIcon "" ui.violet "H";
        hpp = devIcon "" ui.violet "Hpp";
        js = devIcon "" ui.warning "Js";
        jsx = devIcon "" ui.info "Jsx";
        ts = devIcon "" ui.info "TypeScript";
        tsx = devIcon "" ui.info "Tsx";
        json = devIcon "" ui.warning "Json";
        toml = devIcon "" ui.warning "Toml";
        yaml = devIcon "" ui.danger "Yaml";
        yml = devIcon "" ui.danger "Yml";
        md = devIcon "" ui.muted "Md";
        html = devIcon "" ui.danger "Html";
        css = devIcon "" ui.violet "Css";
        scss = devIcon "" ui.violet "Scss";
      };
    };
  };

  vim.utility.snacks-nvim = {
    enable = true;
    setupOpts = {
      explorer.enabled = true;
      picker.enabled = true;
      picker.ui_select = true;
      picker.sources.explorer.hidden = true;
      picker.sources.explorer.ignored = true;
      picker.sources.explorer.exclude = [ "**/.git" ];
      picker.sources.explorer.git_status = true;
      # Keep aggregate Git state visible after opening a directory so it is
      # still obvious which subtree contains changed files.
      picker.sources.explorer.git_status_open = true;
      picker.sources.explorer.layout.hidden = [ "input" ];
      picker.icons.git = {
        staged = "󰄬";
        added = "";
        deleted = "";
        ignored = "";
        modified = "";
        renamed = "";
        unmerged = "";
        untracked = "";
      };
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
    highlight.enable = true;
  };
}
