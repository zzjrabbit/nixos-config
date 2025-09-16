# Fuzzel application launcher module
# This module configures the Fuzzel application launcher for Wayland

{ ... }:

{
  programs.fuzzel = {
    enable = true;
    settings = {
      main = {
        font = "Fira Code Nerd Font:size=9";
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
        background = "1e1e1ed0";
        text = "ffffffd0";
        prompt = "ffffffd0";
        placeholder = "919190d0";
        input = "ffffffd0";
        match = "6fb0ffd0";
        selection = "3070e0d0";
        selection-text = "ffffffd0";
        selection-match = "80b0ffd0";
        counter = "919190d0";
        border = "7fbfffd0";
      };
    };
  };
}