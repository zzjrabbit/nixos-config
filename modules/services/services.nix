{ pkgs, ... }:
{
  services.flatpak = {
    enable = true;
  };

  services.nohang = {
    enable = true;
  };

  # virtualisation.virtualbox.host.enable = true;
  virtualisation = {
    docker = {
      enable = true;
      rootless.enable = true;
    };
  };

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

  hardware.sane = {
    enable = true;
    # Brother DCP-T436W uses Brother's brscan5 SANE backend. AirScan lets
    # network-connected devices be discovered through the existing Avahi setup.
    brscan5.enable = true;
    extraBackends = [ pkgs.sane-airscan ];
  };

  environment.systemPackages = [
    pkgs.fprintd
    pkgs.imagemagick
    pkgs.simple-scan
  ];
  services.fprintd = {
    enable = true;
    package = pkgs.fprintd-tod;
    tod = {
      enable = true;
      driver = pkgs.libfprint-2-tod1-goodix;
    };
  };

  networking.networkmanager = {
    enable = true;
    dns = "default";
    wifi.powersave = false;
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

  services.gvfs = {
    enable = true;
  };
}
