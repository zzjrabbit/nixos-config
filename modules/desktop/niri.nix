{ config, lib, ... }:
{
  config = lib.mkIf config.my.desktop.enable {
    programs.niri.enable = true;
    programs.nm-applet.enable = true;

    environment.sessionVariables.NIXOS_OZONE_WL = "1";
  };
}
