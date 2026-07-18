{ config, ... }:

{
  services.swaync = {
    enable = true;
    settings = {
      positionX = "right";
      positionY = "top";
      layer = "overlay";
      # Keep the layer surfaces content-sized.  With this enabled SwayNC uses
      # a fullscreen transparent surface, which Niri then blurs as if the
      # whole screen belonged to the control center/notification.
      layer-shell-cover-screen = false;
      # These are GTK child margins, not layer-shell margins.  Keeping them at
      # zero makes the visible panel and Niri's blurred surface share bounds.
      control-center-margin-top = 0;
      control-center-margin-bottom = 0;
      control-center-margin-right = 0;
      control-center-margin-left = 0;
      control-center-layer = "overlay";
      notification-icon-size = 48;
      timeout = 5;
      timeout-low = 3;
      timeout-critical = 0;
      fit-to-screen = false;
      control-center-width = 380;
      control-center-height = 520;
      notification-window-width = 340;
      notification-window-height = 480;
      transition-time = 200;
      hide-on-clear = true;
      hide-on-action = false;
      script-fail-notify = true;
      widgets = [
        "title"
        "notifications"
        "mpris"
        "buttons-grid"
      ];
      widget-config = {
        title = {
          text = "通知";
          clear-all-button = true;
          button-text = "清除";
        };
        mpris = {
          image-size = 64;
          image-radius = 12;
        };
        buttons-grid = {
          actions = [
            {
              label = "󰐥";
              command = "systemctl poweroff";
            }
            {
              label = "󰤄";
              command = "systemctl suspend";
            }
            {
              label = "󰜉";
              command = "systemctl reboot";
            }
          ];
        };
      };
    };
    style = ''
      @define-color base00 #${config.lib.stylix.colors.base00};
      @define-color base01 #${config.lib.stylix.colors.base01};
      @define-color base02 #${config.lib.stylix.colors.base02};
      @define-color base04 #${config.lib.stylix.colors.base04};
      @define-color base05 #${config.lib.stylix.colors.base05};
      @define-color base06 #${config.lib.stylix.colors.base06};
      @define-color base07 #${config.lib.stylix.colors.base07};
      @define-color base08 #${config.lib.stylix.colors.base08};
      @define-color base0A #${config.lib.stylix.colors.base0A};
      @define-color base0C #${config.lib.stylix.colors.base0C};
      @define-color base0D #${config.lib.stylix.colors.base0D};
      @define-color cc-bg alpha(@base00, 0.58);
      @define-color noti-border-color alpha(@base06, 0.28);
      @define-color noti-bg-darker alpha(@base01, 0.88);
      @define-color text-color @base05;
      @define-color accent-color @base0D;
      @define-color accent-hover @base0C;

      * {
          font-family: "${config.stylix.fonts.sansSerif.name}";
          font-weight: bold;
          box-shadow: none;
      }

      scrolledwindow overshoot,
      scrolledwindow undershoot {
          box-shadow: none;
          background: transparent;
          border: none;
      }

      notificationwindow,
      blankwindow,
      .blank-window,
      .floating-notifications {
          background: transparent;
      }

      .control-center {
          background: linear-gradient(145deg,
              alpha(@base07, 0.16),
              alpha(@base01, 0.52) 28%,
              alpha(@base00, 0.64));
          border: 1px solid @noti-border-color;
          border-top-color: alpha(@base07, 0.38);
          border-bottom-color: alpha(@base0D, 0.30);
          box-shadow:
              inset 0 1px alpha(@base07, 0.16),
              inset 0 -1px alpha(@base00, 0.30),
              0 12px 36px alpha(@base00, 0.42);
          border-radius: 18px;
      }

      .widget-notifications {
          margin: 0px;
      }

      .notification-group {
          background: transparent;
      }

      .notification-group-headers {
          margin: 8px 12px;
      }

      .notification-group-headers > label {
          font-size: 16px;
      }

      .notification {
          background: linear-gradient(135deg,
              alpha(@base02, 0.94),
              alpha(@base01, 0.88));
          border: 1px solid @noti-border-color;
          border-top-color: alpha(@base07, 0.26);
          border-radius: 16px;
          box-shadow:
              inset 0 1px alpha(@base07, 0.10),
              0 6px 20px alpha(@base00, 0.24);
      }

      .notification-background {
          margin: 6px 8px;
          padding: 0px;
      }

      .notification-content {
          padding: 12px;
      }

      .notification-content .image {
          margin: 0px 12px 0px 0px;
      }

      .notification-content .text-box .time {
          font-size: 12px;
          color: @accent-hover;
          margin: 2px 28px 2px 12px;
      }

      .notification-content .text-box .summary {
          font-size: 15px;
          color: @text-color;
      }

      .notification-content .text-box .body {
          font-size: 13px;
          font-weight: normal;
          color: @text-color;
      }

      .notification-action {
          margin: 0px;
          padding: 0px;
      }

      .notification-action button {
          color: @text-color;
          font-size: 13px;
          background: alpha(@base00, 0.82);
          border: 1px solid @noti-border-color;
          border-radius: 0px;
      }

      .notification-action button:hover {
          color: @text-color;
          background: @noti-bg-darker;
      }

      .notification-alt-actions {
          padding: 0px;
      }

      .notification-default-action:hover {
          color: @text-color;
          background: alpha(@base0D, 0.10);
      }

      .close-button {
          background: linear-gradient(135deg, @accent-color, @accent-hover);
          color: @base00;
          text-shadow: none;
          padding: 0px;
          border-radius: 16px;
          box-shadow: inset 0 1px alpha(@base07, 0.38);
      }

      .close-button:hover {
          box-shadow: none;
          background: @accent-hover;
          transition: all 0.15s ease-in-out;
          border: none;
      }

      .widget-title {
          background: alpha(@base06, 0.07);
          border: 1px solid alpha(@base06, 0.10);
          padding: 8px 12px;
          margin: 12px 12px 6px 12px;
          font-size: 16px;
          border-radius: 14px;
          box-shadow: inset 0 1px alpha(@base07, 0.08);
      }

      .widget-title > label {
          font-size: 16px;
      }

      .widget-title > button {
          font-size: 14px;
          color: @text-color;
          text-shadow: none;
          background: alpha(@base06, 0.07);
          box-shadow: none;
          border-radius: 8px;
      }

      .widget-title > button:hover {
          background: alpha(@accent-color, 0.18);
          color: @base06;
      }

      .widget-mpris {
          margin: -4px 4px;
      }

      .mpris-overlay {
          padding: 16px 16px 8px;
      }

      .widget-mpris-player {
          margin: 8px;
      }

      .widget-mpris-title {
          font-size: 15px;
      }

      .widget-mpris-subtitle {
          font-weight: 600;
          font-size: 13px;
      }

      .widget-buttons-grid {
          font-size: large;
          padding: 7px;
          margin: 5px 10px 10px 10px;
          border-radius: 14px;
          background: alpha(@base06, 0.06);
          border: 1px solid alpha(@base06, 0.09);
      }

      .widget-buttons-grid > flowbox > flowboxchild:hover {
          background: transparent;
      }

      .widget-buttons-grid > flowbox > flowboxchild > button {
          margin: 3px;
          background: alpha(@base01, 0.38);
          border-radius: 11px;
          color: @text-color;
          box-shadow: inset 0 1px alpha(@base07, 0.07);
      }

      .widget-buttons-grid > flowbox > flowboxchild > button:hover {
          background: alpha(@accent-color, 0.18);
          color: @base06;
      }
    '';
  };
}
