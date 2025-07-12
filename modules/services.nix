{ pkgs, lib, config, ... }:
{
  virtualisation.virtualbox.host.enable = true;
  
  networking.enableIPv6 = true;
  networking.firewall = {
    allowPing = true;
    allowedTCPPorts = [ 22 80 443 ];
  };
  
  services.blueman.enable = true;
  hardware.bluetooth = {
    enable = true;
    powerOnBoot = true;
  };
  
  services.avahi = {
    enable = true;
    nssmdns4 = true;
    openFirewall = true;
  };

  services.pipewire = {
    enable = true;
    pulse.enable = true;
  };
  nixpkgs.config.pulseaudio = true;
  
  services.libinput.enable = true;
  services.xserver.enable = true;
  services.udisks2.enable = true;
  services.printing.enable = true;
  
  networking.networkmanager = {
    enable = true;
    dns = "default";
  };
  
  security.polkit.enable = true;
  systemd = {
    user.services.polkit-gnome-authentication-agent-1 = {
      description = "polkit-gnome-authentication-agent-1";
      wantedBy = [ "graphical-session.target" ];
      wants = [ "graphical-session.target" ];
      after = [ "graphical-session.target" ];
      serviceConfig = {
        Type = "simple";
        ExecStart = "${pkgs.polkit_gnome}/libexec/polkit-gnome-authentication-agent-1";
        Restart = "on-failure";
        RestartSec = 1;
        TimeoutStopSec = 10;
      };
    };
 };
 
  services.greetd = {
    enable = true;
    settings = {
      default_session = let
        tuigreet = "${lib.getExe pkgs.greetd.tuigreet}";
        baseSessionsDir = "${config.services.displayManager.sessionData.desktops}";
        xSessions = "${baseSessionsDir}/share/xsessions";
        waylandSessions = "${baseSessionsDir}/share/wayland-sessions";
        tuigreetOptions = [
          "--time"
          "--remember"
          "--remember-session"
          "--sessions ${waylandSessions}:${xSessions}"
        ];
        flags = lib.concatStringsSep " " tuigreetOptions;
      in {
        command = "${tuigreet} ${flags}";
        user = "greeter";
      };
    };
  };
}
