{ config, lib, pkgs, ... }:

{
  dconf = {
    settings = {
      "org/gnome/desktop/interface" = {
        gtk-theme = "adw-gtk3-dark";
        color-scheme = "prefer-dark";
      };
    };
  };

  gtk = {
    enable = true;
    font.name = "Source Han Sans SC";
    theme = {
      name = "adw-gtk3-dark";
      package = pkgs.adw-gtk3;
    };
    iconTheme = {
      name = "Papirus-Dark";
      package = pkgs.papirus-icon-theme;
    };
    gtk3.extraConfig = {
      gtk-application-prefer-dark-theme = 1;
    };
  };

  qt = {
    enable = true;
    platformTheme.name = "adwaita";
    style.name = "adwaita-dark";
  };
}