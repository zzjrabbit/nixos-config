# Shared colour palette for the Neovim configuration.
{ config }:

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
in
{
  inherit ui bufferHighlight bufferText lualineState explorerGit syntax;
}
