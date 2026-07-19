{ config, inputs, pkgs, ... }:

let
  # Neovim chrome uses neutral surfaces and restrained, desaturated state
  # colours. The steps between normal, hover and selected are intentionally
  # small so one component does not jump from near-black to a bright accent.
  ui = {
    bg = "#${config.lib.stylix.colors.base00}";
    surface = "#17191c";
    raised = "#202328";
    hover = "#292d32";
    selected = "#343940";
    active = "#41474f";
    border = "#3a3f45";
    muted = "#858b92";
    text = "#c7cacf";
    bright = "#eceef0";
    accent = "#a9b0b7";
    info = "#8fa1a8";
    success = "#8fa897";
    warning = "#b3a078";
    danger = "#b48886";
    violet = "#9f96aa";
  };

  # Git state needs stronger separation in the explorer than the rest of the
  # deliberately subdued UI. These colours are used for both the status badge
  # and the affected file/directory name, including aggregate directory state.
  explorerGit = {
    added = "#8fcf9f";
    modified = "#e0b866";
    deleted = "#df8581";
    untracked = "#76b9d0";
    staged = "#82b8aa";
    renamed = "#82a9c5";
  };

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
      normal = middle // { a = mode ui.accent; };
      insert = middle // { a = mode ui.success; };
      visual = middle // { a = mode ui.violet; };
      replace = middle // { a = mode ui.danger; };
      command = middle // { a = mode ui.warning; };
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
  ];

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
    };

    vim.highlight = {
      Normal = { bg = "NONE"; fg = ui.text; };
      NormalNC = { bg = "NONE"; fg = ui.muted; };
      NormalFloat = { bg = ui.surface; fg = ui.text; };
      FloatBorder = { bg = ui.surface; fg = ui.border; };
      FloatTitle = { bg = ui.surface; fg = ui.bright; bold = true; };
      Directory = { fg = ui.accent; bold = true; };
      Title = { fg = ui.bright; bold = true; };
      Question.fg = ui.info;
      Conceal.fg = ui.muted;
      SignColumn.bg = "NONE";
      CursorLine.bg = ui.raised;
      CursorLineNr = { bg = ui.raised; fg = ui.accent; bold = true; };
      LineNr = { bg = "NONE"; fg = ui.border; };
      Visual = { bg = ui.selected; fg = ui.bright; };
      Search = { bg = ui.hover; fg = ui.text; };
      IncSearch = { bg = ui.selected; fg = ui.bright; bold = true; };
      CurSearch = { bg = ui.active; fg = ui.bright; bold = true; underline = true; };
      Substitute = { bg = ui.selected; fg = ui.bright; bold = true; };
      MatchParen = { bg = ui.hover; fg = ui.bright; bold = true; };
      Pmenu = { bg = ui.surface; fg = ui.text; };
      PmenuSel = { bg = ui.selected; fg = ui.bright; bold = true; };
      PmenuExtra = { bg = ui.surface; fg = ui.muted; };
      PmenuKind = { bg = ui.surface; fg = ui.accent; };
      PmenuSbar.bg = ui.surface;
      PmenuThumb.bg = ui.border;
      WildMenu = { bg = ui.selected; fg = ui.bright; bold = true; };
      QuickFixLine = { bg = ui.hover; fg = ui.bright; bold = true; };
      Folded = { bg = ui.surface; fg = ui.muted; };
      FoldColumn = { bg = "NONE"; fg = ui.border; };
      ColorColumn.bg = ui.surface;
      NonText.fg = ui.border;
      SpecialKey.fg = ui.border;
      Whitespace.fg = ui.border;
      EndOfBuffer.fg = ui.bg;
      WinSeparator = { bg = "NONE"; fg = ui.border; };
      StatusLine = { bg = ui.surface; fg = ui.text; };
      StatusLineNC = { bg = ui.bg; fg = ui.border; };
      TabLine = { bg = ui.surface; fg = ui.muted; };
      TabLineFill.bg = ui.bg;
      TabLineSel = { bg = ui.selected; fg = ui.bright; bold = true; };
      MsgArea.fg = ui.text;
      ModeMsg = { fg = ui.accent; bold = true; };
      MoreMsg.fg = ui.info;
      ErrorMsg = { fg = ui.danger; bold = true; };
      WarningMsg.fg = ui.warning;

      DiagnosticError.fg = ui.danger;
      DiagnosticWarn.fg = ui.warning;
      DiagnosticInfo.fg = ui.info;
      DiagnosticHint.fg = ui.violet;
      DiagnosticOk.fg = ui.success;
      DiagnosticVirtualTextError = { bg = "NONE"; fg = ui.danger; };
      DiagnosticVirtualTextWarn = { bg = "NONE"; fg = ui.warning; };
      DiagnosticVirtualTextInfo = { bg = "NONE"; fg = ui.info; };
      DiagnosticVirtualTextHint = { bg = "NONE"; fg = ui.violet; };
      DiagnosticFloatingError.fg = ui.danger;
      DiagnosticFloatingWarn.fg = ui.warning;
      DiagnosticFloatingInfo.fg = ui.info;
      DiagnosticFloatingHint.fg = ui.violet;

      DiffAdd = { bg = "#18221d"; fg = ui.success; };
      DiffChange = { bg = "#242219"; fg = ui.warning; };
      DiffDelete = { bg = "#251b1b"; fg = ui.danger; };
      DiffText = { bg = "#302b20"; fg = ui.bright; bold = true; };
      GitSignsAdd.fg = ui.success;
      GitSignsChange.fg = ui.warning;
      GitSignsDelete.fg = ui.danger;
      GitSignsUntracked.fg = ui.accent;

      BlinkCmpMenu = { bg = ui.surface; fg = ui.text; };
      BlinkCmpMenuBorder = { bg = ui.surface; fg = ui.border; };
      BlinkCmpMenuSelection = { bg = ui.selected; fg = ui.bright; bold = true; };
      BlinkCmpLabel.fg = ui.text;
      BlinkCmpLabelMatch = { fg = ui.accent; bold = true; };
      BlinkCmpLabelDetail.fg = ui.muted;
      BlinkCmpLabelDescription.fg = ui.muted;
      BlinkCmpSource.fg = ui.muted;
      BlinkCmpKind.fg = ui.accent;
      BlinkCmpKindFunction.fg = ui.violet;
      BlinkCmpKindMethod.fg = ui.violet;
      BlinkCmpKindConstructor.fg = ui.violet;
      BlinkCmpKindClass.fg = ui.info;
      BlinkCmpKindInterface.fg = ui.info;
      BlinkCmpKindStruct.fg = ui.info;
      BlinkCmpKindEnum.fg = ui.info;
      BlinkCmpKindModule.fg = ui.info;
      BlinkCmpKindText.fg = ui.success;
      BlinkCmpKindString.fg = ui.success;
      BlinkCmpKindKeyword.fg = ui.warning;
      BlinkCmpKindOperator.fg = ui.warning;
      BlinkCmpKindSnippet.fg = ui.danger;
      BlinkCmpScrollBarGutter.bg = ui.surface;
      BlinkCmpScrollBarThumb.bg = ui.border;
      BlinkCmpDoc = { bg = ui.surface; fg = ui.text; };
      BlinkCmpDocBorder = { bg = ui.surface; fg = ui.border; };
      BlinkCmpDocSeparator = { bg = ui.surface; fg = ui.border; };
      BlinkCmpDocCursorLine.bg = ui.hover;
      BlinkCmpSignatureHelp = { bg = ui.surface; fg = ui.text; };
      BlinkCmpSignatureHelpBorder = { bg = ui.surface; fg = ui.border; };
      BlinkCmpSignatureHelpActiveParameter = { fg = ui.accent; bold = true; };

      WhichKeyNormal = { bg = ui.surface; fg = ui.text; };
      WhichKeyBorder = { bg = ui.surface; fg = ui.border; };
      WhichKeyTitle = { bg = ui.surface; fg = ui.bright; bold = true; };
      WhichKey = { fg = ui.accent; bold = true; };
      WhichKeyGroup = { fg = ui.violet; bold = true; };
      WhichKeyDesc.fg = ui.text;
      WhichKeySeparator.fg = ui.border;
      WhichKeyValue.fg = ui.muted;
      WhichKeyIcon.fg = ui.accent;
      WhichKeyIconAzure.fg = ui.info;
      WhichKeyIconBlue.fg = ui.info;
      WhichKeyIconCyan.fg = ui.accent;
      WhichKeyIconGreen.fg = ui.success;
      WhichKeyIconGrey.fg = ui.muted;
      WhichKeyIconOrange.fg = ui.warning;
      WhichKeyIconPurple.fg = ui.violet;
      WhichKeyIconRed.fg = ui.danger;
      WhichKeyIconYellow.fg = ui.warning;
      DevIconDefault.fg = ui.accent;

      SnacksTerminal = { bg = ui.surface; fg = ui.text; };
      SnacksTerminalBorder = { bg = ui.surface; fg = ui.border; };
      SnacksTerminalTitle = { bg = ui.surface; fg = ui.bright; bold = true; };
      SnacksInputNormal = { bg = ui.surface; fg = ui.text; };
      SnacksInputBorder = { bg = ui.surface; fg = ui.border; };
      SnacksInputTitle = { bg = ui.surface; fg = ui.bright; bold = true; };
      SnacksInputIcon.fg = ui.accent;
      SnacksIndent.fg = ui.border;
      SnacksIndentScope.fg = ui.accent;
      SnacksPickerNormal = { bg = ui.surface; fg = ui.text; };
      SnacksPickerBox = { bg = ui.surface; fg = ui.text; };
      SnacksPickerBorder = { bg = ui.surface; fg = ui.border; };
      SnacksPickerTitle = { bg = ui.surface; fg = ui.bright; bold = true; };
      SnacksPickerInput = { bg = ui.surface; fg = ui.text; };
      SnacksPickerInputBorder = { bg = ui.surface; fg = ui.border; };
      SnacksPickerInputTitle = { bg = ui.surface; fg = ui.bright; bold = true; };
      SnacksPickerInputSearch = { fg = ui.accent; bold = true; };
      SnacksPickerList = { bg = ui.surface; fg = ui.text; };
      SnacksPickerListCursorLine = { bg = ui.selected; fg = ui.bright; bold = true; };
      SnacksPickerPreview = { bg = ui.surface; fg = ui.text; };
      SnacksPickerPreviewCursorLine.bg = ui.hover;
      SnacksPickerMatch = { fg = ui.accent; bold = true; };
      SnacksPickerSearch = { bg = ui.hover; fg = ui.bright; bold = true; };
      SnacksPickerPrompt.fg = ui.accent;
      SnacksPickerTotals.fg = ui.muted;
      SnacksPickerSelected = { fg = ui.bright; bold = true; };
      SnacksPickerUnselected.fg = ui.border;
      SnacksPickerFile.fg = ui.text;
      SnacksPickerDirectory = { fg = ui.info; bold = true; };
      SnacksPickerDir.fg = ui.muted;
      SnacksPickerPathHidden.fg = ui.text;
      SnacksPickerPathIgnored.fg = ui.border;
      SnacksPickerTree.fg = ui.border;
      SnacksPickerDimmed.fg = ui.muted;
      SnacksPickerComment.fg = ui.muted;
      SnacksPickerDesc.fg = ui.muted;
      SnacksPickerDelim.fg = ui.border;
      SnacksPickerToggle.fg = ui.info;
      SnacksPickerSpinner.fg = ui.accent;
      SnacksPickerCmd.fg = ui.violet;
      SnacksPickerSpecial.fg = ui.accent;
      SnacksPickerIdx.fg = ui.muted;
      SnacksPickerRow.fg = ui.muted;
      SnacksPickerCol.fg = ui.muted;
      SnacksPickerGitBranch.fg = ui.violet;
      SnacksPickerGitStatus = { fg = ui.bright; bold = true; };
      SnacksPickerGitStatusAdded = { fg = explorerGit.added; bold = true; };
      SnacksPickerGitStatusModified = { fg = explorerGit.modified; bold = true; };
      SnacksPickerGitStatusDeleted = { fg = explorerGit.deleted; bold = true; };
      SnacksPickerGitStatusUntracked = { fg = explorerGit.untracked; bold = true; };
      SnacksPickerGitStatusIgnored = { fg = ui.muted; italic = true; };
      SnacksPickerGitStatusStaged = { fg = explorerGit.staged; bold = true; };
      SnacksPickerGitStatusRenamed = { fg = explorerGit.renamed; bold = true; };
      SnacksPickerGitStatusCopied = { fg = explorerGit.renamed; bold = true; };
      SnacksPickerGitStatusUnmerged = { fg = explorerGit.deleted; bold = true; underline = true; };
      SnacksPickerIcon.fg = ui.accent;
      SnacksPickerIconFile.fg = ui.text;
      SnacksPickerIconFunction.fg = ui.violet;
      SnacksPickerIconMethod.fg = ui.violet;
      SnacksPickerIconClass.fg = ui.info;
      SnacksPickerIconInterface.fg = ui.info;
      SnacksPickerIconStruct.fg = ui.info;
      SnacksPickerIconModule.fg = ui.info;
      SnacksPickerIconString.fg = ui.success;
      SnacksPickerIconKeyword.fg = ui.warning;
      SnacksPickerIconOperator.fg = ui.warning;
      SnacksDashboardNormal = { bg = "NONE"; fg = ui.text; };
      SnacksDashboardHeader.fg = ui.accent;
      SnacksDashboardKey.fg = ui.violet;
      SnacksDashboardIcon.fg = ui.info;
      SnacksDashboardDesc.fg = ui.text;
      SnacksDashboardDir.fg = ui.muted;
      SnacksDashboardFooter.fg = ui.muted;
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
