{
  config,
  lib,
  pkgs,
  ...
}:

let
  colors = config.lib.stylix.colors.withHashtag;
  grubFont = pkgs.runCommand "event-horizon-grub-font.pf2" {
    FONTCONFIG_FILE = pkgs.makeFontsConf {
      fontDirectories = [ config.stylix.fonts.sansSerif.package ];
    };
  } ''
    font=$(
      ${lib.getExe' pkgs.fontconfig "fc-match"} \
        ${lib.escapeShellArg config.stylix.fonts.sansSerif.name} \
        --format=%{file}
    )
    ${lib.getExe' pkgs.grub2 "grub-mkfont"} \
      "$font" \
      --output "$out" \
      --size 18
  '';
  grubTheme = pkgs.runCommand "event-horizon-grub-theme" {
    themeTxt = ''
      desktop-image: "background.png"
      desktop-image-scale-method: "crop"
      desktop-color: "${colors.base00}"

      title-text: ""
      terminal-left: "8%"
      terminal-top: "20%"
      terminal-width: "38%"
      terminal-height: "54%"

      + label {
        left = 8%
        top = 15%
        width = 38%
        align = "left"
        text = "NIXOS"
        font = "${config.stylix.fonts.sansSerif.name}"
        color = "${colors.base07}"
      }

      + boot_menu {
        left = 8%
        top = 20%
        width = 38%
        height = 54%
        menu_pixmap_style = "panel_*.png"

        item_height = 48
        item_icon_space = 12
        item_spacing = 6
        item_padding = 14
        item_font = "${config.stylix.fonts.sansSerif.name}"
        item_color = "${colors.base05}"

        selected_item_color = "${colors.base00}"
        selected_item_pixmap_style = "selection_*.png"
        scrollbar = false
      }

      + label {
        left = 8%
        top = 77%
        width = 38%
        align = "center"
        id = "__timeout__"
        text = "Automatic boot in %d seconds"
        font = "${config.stylix.fonts.sansSerif.name}"
        color = "${colors.base04}"
      }
    '';
    passAsFile = [ "themeTxt" ];
  } ''
    mkdir -p "$out"
    cp "$themeTxtPath" "$out/theme.txt"
    cp ${grubFont} "$out/sans_serif.pf2"

    ${lib.getExe' pkgs.imagemagick "convert"} \
      ${lib.escapeShellArg config.stylix.image} \
      -strip \
      "png32:$out/background.png"

    # GRUB stretches these nine slices around the menu. Keeping the rounded
    # corners and shadow in fixed-size slices avoids distortion at any mode.
    ${lib.getExe' pkgs.imagemagick "convert"} \
      -size 72x72 xc:none \
      \( -size 72x72 xc:none \
        -fill "#00000070" \
        -draw "roundrectangle 6,8 65,67 18,18" \
        -blur 0x4 \) \
      -compose over -composite \
      -fill "${colors.base01}e8" \
      -stroke "${colors.base06}38" \
      -strokewidth 1 \
      -draw "roundrectangle 4,4 67,67 18,18" \
      "$out/panel.png"

    ${lib.getExe' pkgs.imagemagick "convert"} "$out/panel.png" -crop 24x24+0+0 +repage "$out/panel_nw.png"
    ${lib.getExe' pkgs.imagemagick "convert"} "$out/panel.png" -crop 24x24+24+0 +repage "$out/panel_n.png"
    ${lib.getExe' pkgs.imagemagick "convert"} "$out/panel.png" -crop 24x24+48+0 +repage "$out/panel_ne.png"
    ${lib.getExe' pkgs.imagemagick "convert"} "$out/panel.png" -crop 24x24+0+24 +repage "$out/panel_w.png"
    ${lib.getExe' pkgs.imagemagick "convert"} "$out/panel.png" -crop 24x24+24+24 +repage "$out/panel_c.png"
    ${lib.getExe' pkgs.imagemagick "convert"} "$out/panel.png" -crop 24x24+48+24 +repage "$out/panel_e.png"
    ${lib.getExe' pkgs.imagemagick "convert"} "$out/panel.png" -crop 24x24+0+48 +repage "$out/panel_sw.png"
    ${lib.getExe' pkgs.imagemagick "convert"} "$out/panel.png" -crop 24x24+24+48 +repage "$out/panel_s.png"
    ${lib.getExe' pkgs.imagemagick "convert"} "$out/panel.png" -crop 24x24+48+48 +repage "$out/panel_se.png"
    rm "$out/panel.png"

    # A horizontal three-slice keeps the selected row pill-shaped while GRUB
    # stretches its centre to fit labels of different lengths.
    ${lib.getExe' pkgs.imagemagick "convert"} \
      -size 48x48 xc:none \
      -fill "${colors.base0D}ed" \
      -stroke "${colors.base07}70" \
      -strokewidth 1 \
      -draw "roundrectangle 1,1 46,46 13,13" \
      "$out/selection.png"

    ${lib.getExe' pkgs.imagemagick "convert"} "$out/selection.png" -crop 16x48+0+0 +repage "$out/selection_w.png"
    ${lib.getExe' pkgs.imagemagick "convert"} "$out/selection.png" -crop 16x48+16+0 +repage "$out/selection_c.png"
    ${lib.getExe' pkgs.imagemagick "convert"} "$out/selection.png" -crop 16x48+32+0 +repage "$out/selection_e.png"
    rm "$out/selection.png"
  '';
in

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

  # Stylix still supplies GRUB's fallback colors and terminal font. The custom
  # theme adds layout and pixmap details which the generic target cannot express.
  boot.loader.grub.theme = lib.mkForce grubTheme;
}
