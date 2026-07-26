{ config, inputs, pkgs, ... }:

let
  # Keep Neovim chrome aligned with the cool Event Horizon system palette.
  # Warm editorial colours are intentionally confined to buffer content below,
  # so explorers, menus, status components and other UI do not inherit them.
  ui = {
    bg = "#${config.lib.stylix.colors.base00}";
    surface = "#${config.lib.stylix.colors.base01}";
    raised = "#${config.lib.stylix.colors.base02}";
    hover = "#2b3036";
    selected = "#343b44";
    border = "#${config.lib.stylix.colors.base03}";
    muted = "#${config.lib.stylix.colors.base04}";
    text = "#${config.lib.stylix.colors.base05}";
    bright = "#${config.lib.stylix.colors.base07}";
    accent = "#${config.lib.stylix.colors.base0D}";
    info = "#${config.lib.stylix.colors.base0C}";
    success = "#${config.lib.stylix.colors.base0B}";
    warning = "#${config.lib.stylix.colors.base0A}";
    danger = "#${config.lib.stylix.colors.base08}";
    violet = "#${config.lib.stylix.colors.base0E}";
  };

  # Warm state backgrounds belong to buffer-local highlights only. Keeping
  # these separate prevents file trees and floating UI from drifting warm.
  bufferHighlight = {
    search = "#5a4229";
    error = "#2b1b19";
    warning = "#2b2418";
    info = "#18262b";
    hint = "#241f2b";
    ok = "#19271e";
    diffAdd = "#19271e";
    diffChange = "#2b2518";
    diffDelete = "#2d1b1a";
    diffText = "#493a20";
  };

  # Editorial text accents belong to the buffer, not editor chrome. In
  # particular, Markdown strong text should read as warm paper rather than the
  # cool near-white used by menus, titles and selected UI elements.
  bufferText = {
    strong = "#e8c7a7";
  };

  # Lualine communicates mode with a cool blue-to-periwinkle range. Keep this
  # independent from semantic success/warning/error colours so changing mode
  # does not introduce green, amber or coral into the editor chrome.
  lualineState = {
    normal = ui.accent;
    insert = ui.info;
    visual = ui.violet;
    replace = "#8fa7c8";
    command = "#a8bdca";
  };

  # Git state needs stronger separation in the explorer than the rest of the
  # deliberately subdued UI. These colours are used for both the status badge
  # and the affected file/directory name, including aggregate directory state.
  explorerGit = {
    added = "#${config.lib.stylix.colors.base0B}";
    modified = "#${config.lib.stylix.colors.base0A}";
    deleted = "#${config.lib.stylix.colors.base08}";
    untracked = "#${config.lib.stylix.colors.base0C}";
    staged = "#${config.lib.stylix.colors.base0D}";
    renamed = "#${config.lib.stylix.colors.base0E}";
  };

  # Syntax uses Anthropic-like clay, sand, sage and mineral tones. Every colour
  # remains comfortable on the charcoal background, while adjacent semantic
  # roles differ enough in both hue and luminance to be recognised at a glance.
  syntax = {
    comment = "#7f858d";
    keyword = "#eb8b7a";
    function = "#8fc9e3";
    type = "#d7b79c";
    class = "#dfa3b2";
    enum = "#e1ba6e";
    interface = "#9bc9ad";
    struct = "#b8a9d8";
    typeParameter = "#d1a5c4";
    namespace = "#92becf";
    string = "#9dccae";
    number = "#e3a06b";
    constant = "#d9c176";
    operator = "#79c7ce";
    variable = "#ddd8d1";
    parameter = "#c8afd9";
    property = "#adbed0";
    punctuation = "#9298a0";
    markup = "#e3a0a3";
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
      # Neovim only loads project-local configuration after it has been
      # explicitly approved through its hash-based trust database (`:trust`).
      exrc = true;
      endofline = true;
      fixendofline = true;
      grepprg = "${lib.getExe pkgs.ripgrep} --vimgrep --no-heading";
      redrawtime = 100;
      shiftwidth = 4;
      tabstop = 4;
      termguicolors = true;
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

    vim.highlight = {
      Normal = { bg = "NONE"; fg = ui.text; };
      # Keep inactive splits readable; borders and cursorline communicate focus
      # without dimming an entire buffer to comment-level contrast.
      NormalNC = { bg = "NONE"; fg = ui.text; };
      NormalFloat = { bg = ui.surface; fg = ui.text; };
      FloatBorder = { bg = ui.surface; fg = ui.border; };
      FloatTitle = { bg = ui.surface; fg = ui.bright; bold = true; };
      FloatFooter = { bg = ui.surface; fg = ui.muted; italic = true; };
      FloatShadow = { bg = ui.bg; blend = 55; };
      Directory = { fg = ui.accent; bold = true; };
      Title = { fg = ui.bright; bold = true; };
      Question.fg = ui.info;
      Conceal.fg = ui.muted;
      SignColumn.bg = "NONE";
      CursorLine.bg = ui.raised;
      CursorLineNr = { bg = ui.raised; fg = ui.accent; bold = true; };
      LineNr = { bg = "NONE"; fg = ui.border; };
      Visual = { bg = ui.selected; fg = ui.bright; };
      Search = { bg = bufferHighlight.search; fg = ui.bright; bold = true; };
      IncSearch = { bg = ui.warning; fg = ui.bg; bold = true; };
      CurSearch = { bg = ui.accent; fg = ui.bg; bold = true; underline = true; };
      Substitute = { bg = ui.danger; fg = ui.bg; bold = true; };
      MatchParen = { bg = ui.selected; fg = ui.warning; bold = true; underline = true; };
      Pmenu = { bg = ui.surface; fg = ui.text; };
      PmenuSel = { bg = ui.selected; fg = ui.bright; bold = true; };
      PmenuExtra = { bg = ui.surface; fg = ui.muted; };
      PmenuKind = { bg = ui.surface; fg = ui.accent; };
      PmenuMatch = { fg = ui.accent; bold = true; };
      PmenuMatchSel = { bg = ui.selected; fg = ui.warning; bold = true; };
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
      WinBar = { bg = "NONE"; fg = ui.text; bold = true; };
      WinBarNC = { bg = "NONE"; fg = ui.muted; };
      TabLine = { bg = ui.surface; fg = ui.muted; };
      TabLineFill.bg = ui.bg;
      TabLineSel = { bg = ui.selected; fg = ui.bright; bold = true; };
      MsgArea.fg = ui.text;
      ModeMsg = { fg = ui.accent; bold = true; };
      MoreMsg.fg = ui.info;
      ErrorMsg = { fg = ui.danger; bold = true; };
      WarningMsg.fg = ui.warning;
      Error = { fg = ui.danger; bold = true; };
      Underlined = { fg = ui.info; underline = true; };
      SpellBad = { undercurl = true; sp = ui.danger; };
      SpellCap = { undercurl = true; sp = ui.warning; };
      SpellLocal = { undercurl = true; sp = ui.info; };
      SpellRare = { undercurl = true; sp = ui.violet; };

      # Vim syntax groups provide a consistent fallback for filetypes without
      # a Treesitter parser and are also the link targets for semantic groups.
      Comment = { fg = syntax.comment; italic = true; };
      Constant.fg = syntax.constant;
      String.fg = syntax.string;
      Character.fg = syntax.string;
      Number.fg = syntax.number;
      Boolean = { fg = syntax.constant; bold = true; };
      Float.fg = syntax.number;
      Identifier.fg = syntax.variable;
      Function = { fg = syntax.function; bold = true; };
      Statement = { fg = syntax.keyword; bold = true; };
      Conditional.fg = syntax.keyword;
      Repeat.fg = syntax.keyword;
      Label.fg = syntax.markup;
      Operator.fg = syntax.operator;
      Keyword = { fg = syntax.keyword; bold = true; };
      Exception = { fg = syntax.keyword; bold = true; };
      PreProc.fg = syntax.markup;
      Include.fg = syntax.markup;
      Define.fg = syntax.markup;
      Macro = { fg = syntax.markup; bold = true; };
      Type.fg = syntax.type;
      StorageClass = { fg = syntax.keyword; italic = true; };
      Structure.fg = syntax.struct;
      Typedef.fg = syntax.type;
      Special.fg = syntax.operator;
      SpecialChar.fg = syntax.operator;
      Tag.fg = syntax.markup;
      Delimiter.fg = syntax.punctuation;
      Todo = { bg = ui.hover; fg = syntax.constant; bold = true; };

      # Treesitter captures carry the structural distinctions that the base16
      # theme flattens, especially calls vs definitions and fields vs locals.
      "@comment" = { link = "Comment"; };
      "@comment.documentation" = { fg = syntax.comment; italic = true; };
      "@constant" = { link = "Constant"; };
      "@constant.builtin" = { fg = syntax.constant; bold = true; };
      "@constant.macro" = { link = "Macro"; };
      "@string" = { link = "String"; };
      "@string.documentation" = { fg = syntax.string; italic = true; };
      "@string.escape" = { fg = syntax.operator; bold = true; };
      "@string.regexp" = { fg = syntax.operator; };
      "@string.special" = { fg = syntax.constant; };
      "@string.special.path" = { fg = syntax.string; underline = true; };
      "@string.special.symbol" = { fg = syntax.constant; };
      "@string.special.url" = { fg = syntax.operator; underline = true; };
      "@character" = { link = "Character"; };
      "@character.special" = { fg = syntax.operator; };
      "@number" = { link = "Number"; };
      "@number.float" = { link = "Float"; };
      "@boolean" = { link = "Boolean"; };
      "@variable" = { fg = syntax.variable; };
      "@variable.builtin" = { fg = syntax.constant; italic = true; };
      "@variable.parameter" = { fg = syntax.parameter; italic = true; };
      "@variable.parameter.builtin" = { fg = syntax.constant; italic = true; };
      "@variable.member" = { fg = syntax.property; };
      "@property" = { fg = syntax.property; };
      "@function" = { link = "Function"; };
      "@function.builtin" = { fg = syntax.function; italic = true; };
      "@function.call" = { fg = syntax.function; };
      "@function.macro" = { link = "Macro"; };
      "@function.method" = { fg = syntax.function; bold = true; };
      "@function.method.call" = { fg = syntax.function; };
      "@constructor" = { fg = syntax.class; bold = true; };
      "@type" = { link = "Type"; };
      "@type.builtin" = { fg = syntax.type; italic = true; };
      "@type.definition" = { fg = syntax.type; bold = true; };
      "@type.qualifier" = { fg = syntax.keyword; italic = true; };
      "@module" = { fg = syntax.namespace; };
      "@module.builtin" = { fg = syntax.namespace; italic = true; };
      "@attribute" = { fg = syntax.markup; italic = true; };
      "@attribute.builtin" = { fg = syntax.markup; };
      "@keyword" = { link = "Keyword"; };
      "@keyword.coroutine" = { fg = syntax.keyword; bold = true; };
      "@keyword.conditional" = { fg = syntax.keyword; };
      "@keyword.repeat" = { fg = syntax.keyword; };
      "@keyword.exception" = { fg = syntax.keyword; };
      "@keyword.function" = { fg = syntax.keyword; bold = true; };
      "@keyword.operator" = { fg = syntax.operator; };
      "@keyword.return" = { fg = syntax.keyword; bold = true; };
      "@keyword.import" = { fg = syntax.markup; bold = true; };
      "@keyword.type" = { fg = syntax.keyword; };
      "@keyword.modifier" = { fg = syntax.keyword; italic = true; };
      "@keyword.debug" = { fg = ui.warning; };
      "@keyword.directive" = { fg = syntax.markup; };
      "@keyword.directive.define" = { fg = syntax.markup; italic = true; };
      "@label" = { link = "Label"; };
      "@operator" = { link = "Operator"; };
      "@punctuation.delimiter" = { link = "Delimiter"; };
      "@punctuation.bracket" = { fg = syntax.punctuation; };
      "@punctuation.special" = { fg = syntax.operator; };
      "@punctuation.special.markdown" = { fg = syntax.markup; };
      "@tag" = { fg = syntax.markup; bold = true; };
      "@tag.attribute" = { fg = syntax.property; italic = true; };
      "@tag.delimiter" = { fg = syntax.punctuation; };
      "@markup.heading" = { fg = syntax.function; bold = true; };
      "@markup.strong" = { fg = bufferText.strong; bold = true; };
      "@markup.italic" = { fg = ui.text; italic = true; };
      "@markup.strikethrough" = { fg = ui.muted; strikethrough = true; };
      "@markup.link" = { fg = syntax.operator; underline = true; };
      "@markup.link.label" = { fg = syntax.markup; };
      "@markup.link.url" = { fg = syntax.operator; underline = true; };
      "@markup.raw" = { fg = syntax.string; };
      "@markup.list" = { fg = syntax.markup; bold = true; };
      "@markup.quote" = { fg = syntax.comment; italic = true; };
      "@comment.error" = { fg = ui.danger; bold = true; };
      "@comment.warning" = { fg = ui.warning; bold = true; };
      "@comment.todo" = { fg = syntax.constant; bold = true; };
      "@comment.note" = { fg = ui.info; bold = true; };
      "@diff.plus" = { fg = ui.success; };
      "@diff.minus" = { fg = ui.danger; };
      "@diff.delta" = { fg = ui.warning; };

      # LSP semantic tokens take precedence over Treesitter when a server
      # supplies them, so mirror the same roles instead of accepting defaults.
      "@lsp.type.namespace" = { fg = syntax.namespace; };
      "@lsp.type.module" = { fg = syntax.namespace; };
      "@lsp.type.type" = { link = "Type"; };
      "@lsp.type.class" = { fg = syntax.class; };
      "@lsp.type.enum" = { fg = syntax.enum; };
      "@lsp.type.interface" = { fg = syntax.interface; };
      "@lsp.type.struct" = { fg = syntax.struct; };
      "@lsp.type.typeParameter" = { fg = syntax.typeParameter; italic = true; };
      "@lsp.type.parameter" = { fg = syntax.parameter; italic = true; };
      "@lsp.type.variable" = { fg = syntax.variable; };
      "@lsp.type.property" = { fg = syntax.property; };
      "@lsp.type.enumMember" = { fg = syntax.constant; };
      "@lsp.type.function" = { link = "Function"; };
      "@lsp.type.method" = { fg = syntax.function; };
      "@lsp.type.macro" = { link = "Macro"; };
      "@lsp.type.keyword" = { link = "Keyword"; };
      "@lsp.type.comment" = { link = "Comment"; };
      "@lsp.type.string" = { link = "String"; };
      "@lsp.type.number" = { link = "Number"; };
      "@lsp.type.regexp" = { fg = syntax.operator; };
      "@lsp.type.operator" = { link = "Operator"; };
      "@lsp.type.decorator" = { fg = syntax.markup; italic = true; };
      "@lsp.type.event" = { fg = syntax.constant; };
      "@lsp.type.label" = { link = "Label"; };
      # Common language-server extensions (notably rust-analyzer) retain the
      # same semantic vocabulary instead of falling back to editor defaults.
      "@lsp.type.builtinType" = { fg = syntax.type; italic = true; };
      "@lsp.type.typeAlias" = { fg = syntax.type; };
      "@lsp.type.union" = { fg = syntax.struct; };
      "@lsp.type.generic" = { fg = syntax.typeParameter; italic = true; };
      "@lsp.type.lifetime" = { fg = syntax.parameter; italic = true; };
      "@lsp.type.selfKeyword" = { fg = syntax.constant; italic = true; };
      "@lsp.type.boolean" = { link = "Boolean"; };
      "@lsp.type.escapeSequence" = { fg = syntax.operator; bold = true; };
      "@lsp.type.formatSpecifier" = { fg = syntax.operator; };
      "@lsp.type.punctuation" = { fg = syntax.punctuation; };
      "@lsp.mod.deprecated" = { strikethrough = true; };
      "@lsp.mod.readonly" = { fg = syntax.constant; };
      "@lsp.mod.defaultLibrary" = { italic = true; };
      "@lsp.mod.documentation" = { italic = true; };

      DiagnosticError = { fg = ui.danger; bold = true; };
      DiagnosticWarn = { fg = ui.warning; bold = true; };
      DiagnosticInfo.fg = ui.info;
      DiagnosticHint.fg = ui.violet;
      DiagnosticOk.fg = ui.success;
      DiagnosticSignError = { fg = ui.danger; bold = true; };
      DiagnosticSignWarn = { fg = ui.warning; bold = true; };
      DiagnosticSignInfo = { fg = ui.info; bold = true; };
      DiagnosticSignHint = { fg = ui.violet; bold = true; };
      DiagnosticSignOk = { fg = ui.success; bold = true; };
      DiagnosticVirtualTextError = { bg = bufferHighlight.error; fg = ui.danger; };
      DiagnosticVirtualTextWarn = { bg = bufferHighlight.warning; fg = ui.warning; };
      DiagnosticVirtualTextInfo = { bg = bufferHighlight.info; fg = ui.info; };
      DiagnosticVirtualTextHint = { bg = bufferHighlight.hint; fg = ui.violet; };
      DiagnosticVirtualTextOk = { bg = bufferHighlight.ok; fg = ui.success; };
      DiagnosticFloatingError.fg = ui.danger;
      DiagnosticFloatingWarn.fg = ui.warning;
      DiagnosticFloatingInfo.fg = ui.info;
      DiagnosticFloatingHint.fg = ui.violet;
      DiagnosticFloatingOk.fg = ui.success;
      DiagnosticUnderlineError = { undercurl = true; sp = ui.danger; };
      DiagnosticUnderlineWarn = { undercurl = true; sp = ui.warning; };
      DiagnosticUnderlineInfo = { undercurl = true; sp = ui.info; };
      DiagnosticUnderlineHint = { undercurl = true; sp = ui.violet; };
      DiagnosticUnderlineOk = { undercurl = true; sp = ui.success; };
      DiagnosticDeprecated = { fg = ui.muted; strikethrough = true; };
      DiagnosticUnnecessary.fg = ui.muted;

      LspReferenceText.bg = ui.raised;
      LspReferenceRead = { bg = ui.raised; underline = true; };
      LspReferenceWrite = { bg = ui.selected; bold = true; underline = true; };
      LspSignatureActiveParameter = { fg = ui.accent; bold = true; underline = true; };
      LspInlayHint = { bg = ui.raised; fg = ui.muted; italic = true; };
      LspCodeLens = { fg = ui.muted; italic = true; };
      LspCodeLensSeparator.fg = ui.border;

      DiffAdd = { bg = bufferHighlight.diffAdd; fg = explorerGit.added; };
      DiffChange = { bg = bufferHighlight.diffChange; fg = explorerGit.modified; };
      DiffDelete = { bg = bufferHighlight.diffDelete; fg = explorerGit.deleted; };
      DiffText = { bg = bufferHighlight.diffText; fg = ui.bright; bold = true; };
      Added.fg = explorerGit.added;
      Changed.fg = explorerGit.modified;
      Removed.fg = explorerGit.deleted;
      GitSignsAdd.fg = explorerGit.added;
      GitSignsChange.fg = explorerGit.modified;
      GitSignsDelete.fg = explorerGit.deleted;
      GitSignsUntracked.fg = explorerGit.untracked;

      BlinkCmpMenu = { bg = ui.surface; fg = ui.text; };
      BlinkCmpMenuBorder = { bg = ui.surface; fg = ui.border; };
      BlinkCmpMenuSelection = { bg = ui.selected; fg = ui.bright; bold = true; };
      BlinkCmpLabel.fg = ui.text;
      BlinkCmpLabelMatch = { fg = ui.accent; bold = true; };
      BlinkCmpLabelDetail.fg = ui.muted;
      BlinkCmpLabelDescription.fg = ui.muted;
      BlinkCmpSource.fg = ui.muted;
      BlinkCmpKind.fg = ui.accent;
      BlinkCmpKindFunction.fg = ui.accent;
      BlinkCmpKindMethod.fg = ui.accent;
      BlinkCmpKindConstructor.fg = ui.violet;
      BlinkCmpKindClass.fg = ui.violet;
      BlinkCmpKindInterface.fg = ui.info;
      BlinkCmpKindStruct.fg = ui.violet;
      BlinkCmpKindEnum.fg = ui.warning;
      BlinkCmpKindEnumMember.fg = ui.warning;
      BlinkCmpKindModule.fg = ui.info;
      BlinkCmpKindTypeParameter.fg = ui.violet;
      BlinkCmpKindVariable.fg = ui.text;
      BlinkCmpKindField.fg = ui.info;
      BlinkCmpKindProperty.fg = ui.info;
      BlinkCmpKindConstant.fg = ui.warning;
      BlinkCmpKindText.fg = ui.success;
      BlinkCmpKindString.fg = ui.success;
      BlinkCmpKindKeyword.fg = ui.danger;
      BlinkCmpKindOperator.fg = ui.info;
      BlinkCmpKindSnippet.fg = ui.violet;
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
      SnacksPickerPathIgnored = { fg = ui.muted; italic = true; };
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
      SnacksPickerIconFunction.fg = ui.accent;
      SnacksPickerIconMethod.fg = ui.accent;
      SnacksPickerIconClass.fg = ui.violet;
      SnacksPickerIconInterface.fg = ui.info;
      SnacksPickerIconStruct.fg = ui.violet;
      SnacksPickerIconModule.fg = ui.info;
      SnacksPickerIconString.fg = ui.success;
      SnacksPickerIconKeyword.fg = ui.danger;
      SnacksPickerIconOperator.fg = ui.info;
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
        key = "<leader><Tab>n";
        action = "<cmd>tabnew<cr>";
        desc = "New tab";
      }
      {
        mode = "n";
        key = "<leader><Tab>h";
        action = "<cmd>tabprevious<cr>";
        desc = "Previous tab";
      }
      {
        mode = "n";
        key = "<leader><Tab>l";
        action = "<cmd>tabnext<cr>";
        desc = "Next tab";
      }
      {
        mode = "n";
        key = "<leader><Tab>c";
        action = "<cmd>tabclose<cr>";
        desc = "Close tab";
      }
      {
        mode = "n";
        key = "<leader><Tab>o";
        action = "<cmd>tabonly<cr>";
        desc = "Close other tabs";
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
      {
        mode = "n";
        key = "<leader>lr";
        action = "<cmd>LeanRestartFile<cr>";
        desc = "Restart Lean file";
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
