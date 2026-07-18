{ config, lib, ... }:
{
  programs.alacritty = {
    enable = true;
    settings = {
      terminal.shell = {
        program = "dash";
      };
      env.TERM = "xterm-256color";
      scrolling.multiplier = 5;
      selection.save_to_clipboard = true;
      # Codex delegates mouse text selection to the terminal.  Stylix's base02
      # selection is too close to the near-black background, so use the desktop
      # accent with dark text for a clearly visible selection in the prompt.
      colors.selection = {
        background = lib.mkForce "#${config.lib.stylix.colors.base0D}";
        text = lib.mkForce "#${config.lib.stylix.colors.base00}";
      };
    };
  };
}
