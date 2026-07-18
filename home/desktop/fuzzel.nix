# Fuzzel application launcher module
# This module configures the Fuzzel application launcher for Wayland

{ config, lib, ... }:

{
  programs.fuzzel = {
    enable = true;
    settings = {
      main = {
        width = 42;
        lines = 10;
        horizontal-pad = 24;
        vertical-pad = 18;
        inner-pad = 14;
        line-height = 22;
        image-size-ratio = 1;
        dpi-aware = true;
        fields = "filename,name,generic,categories,keywords";
      };
      border = {
        width = 1;
        radius = 20;
      };
      colors = {
        background = lib.mkForce "${config.lib.stylix.colors.base00}8c";
        text = lib.mkForce "${config.lib.stylix.colors.base05}ff";
        prompt = lib.mkForce "${config.lib.stylix.colors.base0D}ff";
        placeholder = lib.mkForce "${config.lib.stylix.colors.base04}ff";
        input = lib.mkForce "${config.lib.stylix.colors.base06}ff";
        match = lib.mkForce "${config.lib.stylix.colors.base0A}ff";
        selection = lib.mkForce "${config.lib.stylix.colors.base02}b8";
        selection-text = lib.mkForce "${config.lib.stylix.colors.base07}ff";
        selection-match = lib.mkForce "${config.lib.stylix.colors.base0D}ff";
        counter = lib.mkForce "${config.lib.stylix.colors.base04}ff";
        border = lib.mkForce "${config.lib.stylix.colors.base06}52";
      };
    };
  };
}
