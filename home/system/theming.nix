{ ... }:

{
  home.pointerCursor.enable = true;

  stylix.targets = {
    nvf = {
      plugin = "mini-base16";
      transparentBackground = true;
    };

    # Keep the existing layouts and source their colors from the Stylix palette.
    fcitx5.enable = false;
    swaync.enable = false;
    waybar.addCss = false;
  };
}
