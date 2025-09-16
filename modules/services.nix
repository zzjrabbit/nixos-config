{ pkgs, config, ... }:
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
  
  programs.regreet = {
    enable = true;
    settings = {
      background = {
        path = ../wallpaper/sea.jpg;
        fit = "Fill";
      };
    };
    font = {
      name = "Fira Code";
      package = pkgs.fira-code;
    };
    theme = {
      name = "adw-gtk3-dark";
      package = pkgs.adw-gtk3;
    };
    iconTheme = {
      name = "Papirus-Dark";
      package = pkgs.papirus-icon-theme;
    };
  };
  
  services.greetd = {
    enable = true;
    settings = {
      default_session = let
      sway-conf = pkgs.writeText "sway-gtkgreet-config" ''
          exec "${config.programs.regreet.package}/bin/regreet; ${config.programs.sway.package}/bin/swaymsg exit"
          include /etc/sway/config.d/*
        '';
      in {
        command = "${config.programs.sway.package}/bin/sway --config ${sway-conf}";
        user = "greeter";
      };
    };
  };
}
