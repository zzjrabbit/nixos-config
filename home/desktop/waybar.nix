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

		"custom/logo" = {
			format = "";
			tooltip = false;
			"on-click" = "fuzzel";
		};
      };
    };
    style = ''
	  @define-color workspacebackground transparent;
      @define-color bordercolor #FFFFFF;
      @define-color textcolor1 #000000;
      @define-color textcolor2 #FFFFFF;
      @define-color iconcolor #FFFFFF;

      /* -----------------------------------------------------
       * General
       * ----------------------------------------------------- */

      * {
          font-family: "Fira Code Nerd Font";
          border: none;
          border-radius: 0px;
      }

      window#waybar {
          background-color: transparent;
          border-bottom: 0px solid #ffffff;
          transition-property: background-color;
          transition-duration: 0.5s;
      }

      /* -----------------------------------------------------
       * Workspaces
       * ----------------------------------------------------- */

      #workspaces {
          background-color: transparent;
      }

      #workspaces button {
          all: initial;
          min-width: 0;
          box-shadow: inset 0 -3px transparent;
          
          padding: 6px 18px;
          margin: 10px 3px;
          border-radius: 8px;

		  background-color: transparent;
		  color: @textcolor2;
      }

      #workspaces button.active {
          color: #c0e8ff;
          background-color: transparent;
          padding: 2px 32px;
      }

      #workspaces button:hover {
          box-shadow: inherit;
          text-shadow: inherit;
          color: #c0e8ff;
          background-color: @workspacesbackground;
      }
      
      #workspaces button.urgent {
          background-color: @workspacebackground;
      }

      /* -----------------------------------------------------
       * Tooltips
       * ----------------------------------------------------- */

      tooltip {
          border-radius: 4px;
          background: @background;
          text-shadow: none;
		  background-color: transparent;
      }

      tooltip label {
          color: @textcolor2;
      }

      #pulseaudio,
      #battery,
      #custom-notification,
      #clock {
          font-weight: bold;
          color: @iconcolor;
          padding: 4px 10px 4px 10px;
          font-size: 14px;
      }
      
      #custom-notification {
		  background-color: transparent;
          font-size: 14px;
          color: #ffffff;
          border-radius: 6px;
          margin-top: 6px;
		  margin-bottom: 6px;
		  margin-left: 3px;
		  margin-right: 16px;
          padding: 6px 12px;
      }

	  #custom-logo {
			padding-right: 10px;
  		padding-left: 10px;
  		margin-left: 16px;
  		margin-right: 8px;
      font-size: 15px;
  		border-radius: 8px 0px 0px 8px;
  		color: #e0e8ff;
	  }

      #clock {
          background-color: transparent;
          font-size: 14px;
          color: @textcolor2;
          border-radius: 6px;
          margin: 4px 3px;
          padding: 12px 24px;
      }

      /* -----------------------------------------------------
       * Pulseaudio
       * ----------------------------------------------------- */

      #pulseaudio {
		  background-color: transparent;
          font-size: 14px;
          color: @textcolor2;
          border-radius: 4px;
          margin: 6px 3px;
          padding: 6px 12px;
      }

      #pulseaudio.muted {
		  background-color: transparent;
          color: @textcolor2;
      }

      /* -----------------------------------------------------
       * Battery
       * ----------------------------------------------------- */

      #battery {
		  background-color: transparent;
          font-size: 14px;
          color: @textcolor2;
          border-radius: 6px;
          margin: 6px 3px;
          padding: 6px 12px;
      }

      #battery.charging,
      #battery.plugged {
          color: @textcolor2;
		  background-color: transparent;
      }

      @keyframes blink {
          to {
              background-color: rgb(0x10, 0x10, 0x20);
              color: @textcolor2;
          }
      }

      #battery.critical:not(.charging) {
		  background-color: transparent;
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
          border-radius: 6px;
          margin: 4px 3px;
          padding: 12px 12px;
		  background-color: transparent;
      }

      #tray > .passive {
          -gtk-icon-effect: dim;
      }

      #tray > .needs-attention {
          -gtk-icon-effect: highlight;
		  background-color: transparent;
      }
    '';
  };
}
