{ pkgs, ... }:

{
  programs.dconf.enable = true;

  stylix = {
    enable = true;
    image = ../wallpaper/wandering.jpg;
    # Carbon black is the shared base background for every Stylix target;
    # the lighter neutral steps are reserved for raised surfaces.
    base16Scheme = {
      system = "base16";
      scheme = "Event Horizon";
      slug = "event-horizon";
      author = "Curated for wallpaper/wandering.jpg";
      variant = "dark";
      base00 = "0d0d0d";
      base01 = "15171a";
      base02 = "24272b";
      base03 = "555b63";
      base04 = "858b93";
      base05 = "d0d2d5";
      base06 = "e7e8ea";
      base07 = "f7f7f8";
      base08 = "ed7b78";
      base09 = "c98b5c";
      base0A = "ddb979";
      base0B = "8fc6a6";
      base0C = "78c8d8";
      base0D = "78c2eb";
      base0E = "a9b9da";
      base0F = "b98770";
    };
    polarity = "dark";

    fonts = {
      serif = {
        package = pkgs.noto-fonts;
        name = "Noto Serif";
      };
      sansSerif = {
        package = pkgs.noto-fonts;
        name = "Noto Sans";
      };
      monospace = {
        package = pkgs.nerd-fonts.fira-code;
        name = "FiraCode Nerd Font";
      };
      emoji = {
        package = pkgs.noto-fonts-color-emoji;
        name = "Noto Color Emoji";
      };
      sizes = {
        desktop = 10;
        applications = 12;
        terminal = 14;
        popups = 10;
      };
    };

    icons = {
      enable = true;
      package = pkgs.papirus-icon-theme;
      light = "Papirus";
      dark = "Papirus-Dark";
    };

    cursor = {
      package = pkgs.bibata-cursors;
      name = "Bibata-Modern-Ice";
      size = 24;
    };

    opacity = {
      desktop = 0.85;
      applications = 0.7;
      terminal = 0.88;
      popups = 0.92;
    };

    # Keep the boot menu on the same Event Horizon palette and wallpaper as
    # the desktop instead of using a separate, unrelated GRUB theme.
    targets.grub = {
      enable = true;
      useWallpaper = true;
    };
  };
}
