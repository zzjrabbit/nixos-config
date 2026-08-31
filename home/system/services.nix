# System services module
# This module configures user-level systemd services for the desktop environment

{ pkgs, ... }:

{
  services.wpaperd = {
    enable = true;
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
  
}
