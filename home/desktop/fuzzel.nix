# Fuzzel application launcher module
# This module configures the Fuzzel application launcher for Wayland

{ ... }:

{
  programs.fuzzel = {
    enable = true;
    settings = {
      main = {
        font = "SauceCodePro Nerd Font:size=9";
        icon-theme = "BigSur";
        lines = 10;
        horizontal-pad = 16;
        vertical-pad = 12;
        inner-pad = 12;
        line-height = 16;
        image-size-ratio = 0;
        dpi-aware = true;
        fields = "filename,name,generic,categories,keywords";
      };
      border = {
        width = 2;
        radius = 12;
      };
      colors = {
        background = "1e1e1eff";
        text = "ffffffff";
        prompt = "ffffffff";
        placeholder = "919190ff";
        input = "ffffffff";
        match = "a5e3ffff";
        selection = "215d9cff";
        selection-text = "ffffffff";
        selection-match = "a5e3ffff";
        counter = "919190ff";
        border = "215d9cff";
      };
    };
  };
}