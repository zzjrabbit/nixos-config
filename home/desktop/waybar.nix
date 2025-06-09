# Waybar configuration module
# This module configures the Waybar status bar for Wayland

{ ... }:

{
  programs.waybar = {
    enable = true;
    systemd.enable = true;
    settings = {
      mainBar = {
        layer = "top";
        height = 30;
        spacing = 4;

        # Modules positioning
        modules-left = [
          "custom/appmenu"
          "clock"
        ];
        modules-center = [
          "niri/workspaces"
        ];
        modules-right = [
          "tray"
          "pulseaudio"
          "cpu"
          "memory"
          "keyboard-state"
          "battery"
          "custom/notification"
        ];

        # Module configurations
        "niri/workspaces" = {
          format = "{icon}";
        };

        "custom/appmenu" = {
          format = "Apps";
          on-click = "fuzzel";
          tooltip = false;
        };

        tray = {
          icon-size = 16;
          spacing = 16;
        };

        clock = {
          tooltip = false;
          format = "{:%H:%M}  ";
          format-alt = "{:%b %d, %Y (%a)} 󰃰 ";
        };

        cpu = {
          format = "| C {usage}% ";
        };

        memory = {
          format = "| M {}% ";
        };

        battery = {
          states = {
            warning = 30;
            critical = 15;
          };
          format = "{capacity}% {icon}";
          format-icons = [" " " " " " " " " "];
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
            notification = "<span foreground='red'><sup></sup></span>";
            none = "";
            "dnd-notification" = "<span foreground='red'><sup></sup></span>";
            "dnd-none" = "";
            "inhibited-notification" = "<span foreground='red'><sup></sup></span>";
            "inhibited-none" = "";
            "dnd-inhibited-notification" = "<span foreground='red'><sup></sup></span>";
            "dnd-inhibited-none" = "";
          };
          "return-type" = "json";
          "exec-if" = "which swaync-client";
          exec = "swaync-client -swb";
          "on-click" = "swaync-client -t -sw";
          "on-click-right" = "swaync-client -d -sw";
          escape = true;
        };
      };
    };
    style = ''
      @define-color background #FFFFFF;
      @define-color workspacesbackground1 #FFFFFF;
      @define-color workspacesbackground2 #CCCCCC;
      @define-color bordercolor #FFFFFF;
      @define-color textcolor1 #000000;
      @define-color textcolor2 #FFFFFF;
      @define-color iconcolor #FFFFFF;

      /* -----------------------------------------------------
       * General
       * ----------------------------------------------------- */

      * {
          font-family: "SauceCodePro Nerd Font";
          border: none;
          border-radius: 0px;
      }

      window#waybar {
          background-color: rgba(0, 0, 0, 0.2);
          border-bottom: 0px solid #ffffff;
          transition-property: background-color;
          transition-duration: 0.5s;
      }

      /* -----------------------------------------------------
       * Workspaces
       * ----------------------------------------------------- */

      #workspaces {
          margin: 5px 1px 6px 1px;
          padding: 0px 1px;
          border-radius: 15px;
          border: 0px;
          font-weight: bold;
          font-style: normal;
          font-size: 14px;
          color: @textcolor1;
      }

      #workspaces button {
          padding: 0px 5px;
          margin: 4px 3px;
          border-radius: 15px;
          border: 0px;
          color: @textcolor2;
          transition: all 0.3s ease-in-out;
      }

      #workspaces button.active {
          color: @textcolor1;
          background: @workspacesbackground2;
          border-radius: 15px;
          min-width: 40px;
          transition: all 0.3s ease-in-out;
      }

      #workspaces button:hover {
          color: @textcolor1;
          background: @workspacesbackground2;
          border-radius: 15px;
      }

      /* -----------------------------------------------------
       * Tooltips
       * ----------------------------------------------------- */

      tooltip {
          border-radius: 8px;
          background: @background;
          text-shadow: none;
      }

      tooltip label {
          color: @textcolor1;
      }

      /* -----------------------------------------------------
       * Window
       * ----------------------------------------------------- */

      #window {
          background: @background;
          margin: 10px 15px 10px 0px;
          padding: 2px 10px 0px 10px;
          border-radius: 12px;
          color: @textcolor1;
          font-size: 14px;
          font-weight: normal;
      }

      window#waybar.empty #window {
          background-color: transparent;
      }

      /* -----------------------------------------------------
       * Modules
       * ----------------------------------------------------- */

      .modules-left > widget:first-child > #workspaces {
          margin-left: 0;
      }

      .modules-right > widget:last-child > #workspaces {
          margin-right: 0;
      }

      /* -----------------------------------------------------
       * Custom Quicklinks
       * ----------------------------------------------------- */

      #pulseaudio,
      #battery,
      #custom-notification,
      #custom-appmenu,
      #clock {
          font-weight: bold;
          color: @iconcolor;
          padding: 4px 10px 4px 10px;
          font-size: 14px;
      }

      /* -----------------------------------------------------
       * Custom Modules
       * ----------------------------------------------------- */

      #custom-appmenu {
          background-color: @background;
          color: @textcolor1;
          border-radius: 15px;
          margin: 10px 10px 10px 10px;
      }

      /* -----------------------------------------------------
       * Custom Notification
       * ----------------------------------------------------- */

      #custom-notification {
          margin: 2px 20px 0px 8px;
          padding: 0px;
          color: @iconcolor;
      }

      /* -----------------------------------------------------
       * Hardware Group
       * ----------------------------------------------------- */

      #memory,
      #cpu {
          margin: 0px;
          padding: 0px;
          font-size: 14px;
          color: @iconcolor;
      }

      /* -----------------------------------------------------
       * Clock
       * ----------------------------------------------------- */

      #clock {
          background-color: @background;
          font-size: 14px;
          color: @textcolor1;
          border-radius: 15px;
          margin: 10px 7px 10px 0px;
      }

      /* -----------------------------------------------------
       * Pulseaudio
       * ----------------------------------------------------- */

      #pulseaudio {
          background-color: @background;
          font-size: 14px;
          color: @textcolor1;
          border-radius: 15px;
          margin: 10px 10px 10px 0px;
      }

      #pulseaudio.muted {
          background-color: @background;
          color: @textcolor1;
      }

      /* -----------------------------------------------------
       * Battery
       * ----------------------------------------------------- */

      #battery {
          background-color: @background;
          font-size: 14px;
          color: @textcolor1;
          border-radius: 15px;
          margin: 10px 10px 10px 0px;
      }

      #battery.charging,
      #battery.plugged {
          color: @textcolor1;
          background-color: @background;
      }

      @keyframes blink {
          to {
              background-color: @background;
              color: @textcolor1;
          }
      }

      #battery.critical:not(.charging) {
          background-color: #f53c3c;
          color: @textcolor2;
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
          margin: 0px 10px 0px 0px;
      }

      #tray > .passive {
          -gtk-icon-effect: dim;
      }

      #tray > .needs-attention {
          -gtk-icon-effect: highlight;
          background-color: #eb4d4b;
      }
    '';
  };
}