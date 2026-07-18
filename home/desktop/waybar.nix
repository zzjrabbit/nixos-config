# Waybar configuration module
# This module configures the Waybar status bar for Wayland

{ config, ... }:

{
  programs.waybar = {
    enable = true;
    systemd.enable = true;
    settings = {
      mainBar = {
        layer = "top";
        height = 44;
        spacing = 0;
        margin-top = 8;
        margin-left = 14;
        margin-right = 14;

        # Modules positioning
        modules-left = [
          "custom/logo"
          "niri/workspaces"
        ];
        modules-center = [
          "clock"
        ];
        modules-right = [
          "tray"
          "pulseaudio"
          "keyboard-state"
          "battery"
          "custom/notification"
        ];

        # Module configurations
        "niri/workspaces" = {
          format = "{icon}";
        };

        tray = {
          icon-size = 16;
          spacing = 16;
        };

        clock = {
          tooltip = false;
          format = "{:%Y/%m/%d %H:%M}";
        };

        battery = {
          states = {
            warning = 30;
            critical = 15;
          };
          format = "{icon} {capacity}%";
          format-icons = ["󰂎" "󰁺" "󰁻" "󰁼" "󰁽" "󰁾" "󰁿" "󰂀" "󰂁" "󰁹"];
        };

        pulseaudio = {
          format = "{icon} {volume}%";
          format-muted = " {volume}%";
          format-bluetooth = "{icon} {volume}% ";
          format-bluetooth-muted = " {volume}% ";
          format-icons = {
            headphone = " ";
            phone = " ";
            car = " ";
            default = [" " " " " "];
          };
          on-click = "pavucontrol";
        };

        "custom/notification" = {
          tooltip = false;
          format = "{icon}";
          "format-icons" = {
            notification = "<span foreground='#${config.lib.stylix.colors.base08}'><sup></sup></span>";
            none = "";
            "dnd-notification" = "<span foreground='#${config.lib.stylix.colors.base08}'><sup></sup></span>";
            "dnd-none" = "";
            "inhibited-notification" = "<span foreground='#${config.lib.stylix.colors.base08}'><sup></sup></span>";
            "inhibited-none" = "";
            "dnd-inhibited-notification" = "<span foreground='#${config.lib.stylix.colors.base08}'><sup></sup></span>";
            "dnd-inhibited-none" = "";
          };
          "return-type" = "json";
          "exec-if" = "which swaync-client";
          exec = "swaync-client -swb";
          "on-click" = "swaync-client -t -sw";
          "on-click-right" = "swaync-client -d -sw";
          escape = true;
        };

        "custom/logo" = {
          format = "";
          tooltip = false;
          "on-click" = "fuzzel";
        };
      };
    };
    style = ''
      @define-color base00 #${config.lib.stylix.colors.base00};
      @define-color base01 #${config.lib.stylix.colors.base01};
      @define-color base02 #${config.lib.stylix.colors.base02};
      @define-color base03 #${config.lib.stylix.colors.base03};
      @define-color base04 #${config.lib.stylix.colors.base04};
      @define-color base05 #${config.lib.stylix.colors.base05};
      @define-color base06 #${config.lib.stylix.colors.base06};
      @define-color base07 #${config.lib.stylix.colors.base07};
      @define-color base08 #${config.lib.stylix.colors.base08};
      @define-color base09 #${config.lib.stylix.colors.base09};
      @define-color base0A #${config.lib.stylix.colors.base0A};
      @define-color base0B #${config.lib.stylix.colors.base0B};
      @define-color base0C #${config.lib.stylix.colors.base0C};
      @define-color base0D #${config.lib.stylix.colors.base0D};
      @define-color glass alpha(@base00, 0.01);
      @define-color glass-hover alpha(@base06, 0.07);
      @define-color glass-line alpha(@base06, 0.16);
      @define-color muted alpha(@base05, 0.68);

      /* -----------------------------------------------------
       * General
       * ----------------------------------------------------- */

      * {
          border: none;
          min-height: 0;
      }

      window#waybar {
          color: @base05;
          background: @glass;
          border: 1px solid @glass-line;
          border-radius: 16px;
          box-shadow: 0 6px 20px alpha(@base00, 0.28);
      }

      /* -----------------------------------------------------
       * Workspaces
       * ----------------------------------------------------- */

      #workspaces {
          background: transparent;
          margin: 5px 0;
          padding: 2px 3px;
      }

      #workspaces button {
          all: initial;
          min-width: 0;
          padding: 5px 12px;
          margin: 0 2px;
          border-radius: 7px;
          background: transparent;
          color: @muted;
          transition-property: background-color, color;
          transition-duration: 160ms;
      }

      #workspaces button.active {
          color: @base06;
          background: alpha(@base0D, 0.14);
          box-shadow: inset 0 -2px alpha(@base0D, 0.78);
      }

      #workspaces button:hover {
          color: @base06;
          background: @glass-hover;
      }
      
      #workspaces button.urgent {
          background-color: @base08;
          color: @base00;
      }

      /* -----------------------------------------------------
       * Tooltips
       * ----------------------------------------------------- */

      tooltip {
          border: 1px solid @glass-line;
          border-radius: 9px;
          background: alpha(@base00, 0.90);
          box-shadow: 0 5px 18px alpha(@base00, 0.30);
          text-shadow: none;
      }

      tooltip label {
          color: @base05;
      }

      /* Tray context menus are GTK menus rendered by Waybar. Give them an
       * explicit opaque palette so neither the GTK fallback theme nor the
       * wallpaper can tint the Fcitx menu yellow. */
      menu {
          color: @base05;
          background-color: @base01;
          background-image: none;
          border: 1px solid @base03;
          border-radius: 8px;
          padding: 4px;
          opacity: 1;
      }

      menuitem {
          color: @base05;
          background-color: @base01;
          background-image: none;
          border-radius: 5px;
          padding: 5px 9px;
      }

      menuitem:hover {
          color: @base00;
          background-color: @base0D;
      }

      menu separator {
          min-height: 1px;
          margin: 4px 6px;
          background-color: @base03;
      }

      #pulseaudio,
      #battery,
      #keyboard-state,
      #custom-notification,
      #clock {
          font-weight: bold;
          color: @base05;
          padding: 5px 11px;
          font-size: 14px;
          border-radius: 7px;
          transition-property: background-color, color;
          transition-duration: 160ms;
      }

      #pulseaudio:hover,
      #battery:hover,
      #keyboard-state:hover,
      #custom-notification:hover {
          color: @base06;
          background: @glass-hover;
      }

      #custom-notification {
          margin: 5px 10px 5px 1px;
      }

      #custom-logo {
          min-width: 18px;
          padding: 5px 11px;
          margin: 5px 8px 5px 7px;
          font-size: 16px;
          border-radius: 7px;
          color: @base0A;
          background: transparent;
      }

      #clock {
          color: @base06;
          background: transparent;
          margin: 5px 3px;
          padding: 5px 18px;
      }

      /* -----------------------------------------------------
       * Pulseaudio
       * ----------------------------------------------------- */

      #pulseaudio {
          margin: 5px 1px;
      }

      #pulseaudio.muted {
          color: @muted;
      }

      /* -----------------------------------------------------
       * Battery
       * ----------------------------------------------------- */

      #battery {
          margin: 5px 1px;
      }

      #battery.charging,
      #battery.plugged {
          color: @base0B;
      }

      #battery.warning:not(.charging) {
          color: @base0A;
      }

      @keyframes blink {
          to {
              background-color: @base01;
              color: @base08;
          }
      }

      #battery.critical:not(.charging) {
          color: @base08;
          animation-name: blink;
          animation-duration: 0.5s;
          animation-timing-function: linear;
          animation-iteration-count: infinite;
          animation-direction: alternate;
      }

      /* -----------------------------------------------------
       * Tray
       * ----------------------------------------------------- */

      #tray {
          border-radius: 9px;
          margin: 6px 1px 6px 7px;
          padding: 5px 12px;
          background: alpha(@base06, 0.07);
          border: 1px solid alpha(@base06, 0.12);
          box-shadow: 0 2px 8px alpha(@base00, 0.20);
      }

      #tray > .passive {
          -gtk-icon-effect: dim;
          opacity: 0.72;
      }

      #tray > .needs-attention {
          -gtk-icon-effect: highlight;
          color: @base0A;
          background: alpha(@base0A, 0.14);
          box-shadow: inset 0 -2px alpha(@base0A, 0.70);
          border-radius: 6px;
      }
    '';
  };
}
