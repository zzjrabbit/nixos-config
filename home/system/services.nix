# System services module
# This module configures user-level systemd services for the desktop environment

{ lib, pkgs, ... }:

{
  services.wpaperd = {
    enable = true;
    settings.any.path = ../../wallpaper/sea.jpg;
  };
  
  services.hypridle = {
    enable = true;
  };

  services.udiskie = {
    enable = true;
    settings = {
        program_options = {
            file_manager = "${pkgs.nautilus}/bin/nautilus";
        };
    };
  };
  
  # X Wayland Satellite
  systemd.user.services = {
    xwayland-satellite = {
      Unit = {
        PartOf = [ "niri.service" ];
        After = [ "niri.service" ];
      };

      Service = {
        ExecStart = lib.getExe pkgs.xwayland-satellite;
        Restart = "on-failure";
      };

      Install.WantedBy = ["niri.service"];
    };
  };
}