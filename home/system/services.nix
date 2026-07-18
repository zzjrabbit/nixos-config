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
  
  systemd.user.services = {
      polkit-gnome-agent = {
        Unit = {
          description = "PolicyKit Authentication Agent";
          Wants = [ "graphical-session.target" ];
          After = [ "graphical-session.target" ];
        };
        Install = {
          WantedBy = [ "graphical-session.target" ];
        };
        Service = {
          Type = "simple";
          ExecStart = "${pkgs.polkit_gnome}/libexec/polkit-gnome-authentication-agent-1";
          Restart = "on-failure";
          RestartSec = 1;
          TimeoutStopSec = 10;
        };
      };
    };
}
