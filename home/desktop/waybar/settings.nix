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
  };
}
