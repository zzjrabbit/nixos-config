{ ... }:

{
  services.swaync = {
    enable = true;
    settings = {
      positionX = "right";
      positionY = "top";
      layer = "overlay";
      control-center-margin-top = 6;
      control-center-margin-bottom = 6;
      control-center-margin-right = 6;
      control-center-margin-left = 6;
      control-center-layer = "overlay";
      notification-icon-size = 48;
      timeout = 5;
      timeout-low = 3;
      timeout-critical = 0;
      fit-to-screen = false;
      control-center-width = 400;
      control-center-height = 550;
      notification-window-width = 400;
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
      @define-color cc-bg #242424;
      @define-color noti-border-color #303030;
      @define-color noti-bg-darker #303030;
      @define-color text-color #ffffff;

      * {
          font-family: SourceCodePro;
          font-weight: bold;
          box-shadow: none;
      }

      scrolledwindow overshoot,
      scrolledwindow undershoot {
          box-shadow: none;
          background: transparent;
          border: none;
      }

      .control-center {
          background: @cc-bg;
          box-shadow: inset 0 0 0 2px #215d9c;
          border-radius: 12px;
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
          background: @cc-bg;
          border: 2px solid #215d9c;
          border-radius: 12px;
      }

      .notification-background {
          margin: 6px 12px;
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
          color: #62a0ea;
          margin: 2px 28px 2px 12px;
      }

      .notification-content .text-box .summary {
          font-size: 15px;
          color: #ffffff;
      }

      .notification-content .text-box .body {
          font-size: 13px;
          font-weight: normal;
          color: #ffffff;
      }

      .notification-action {
          margin: 0px;
          padding: 0px;
      }

      .notification-action button {
          color: #ffffff;
          font-size: 13px;
          background: @cc-bg;
          border: 1px solid @noti-border-color;
          border-radius: 0px;
      }

      .notification-action button:hover {
          color: #ffffff;
          background: #303030;
      }

      .notification-alt-actions {
          padding: 0px;
      }

      .notification-default-action:hover {
          color: #ffffff;
          background: #303030;
      }

      .close-button {
          background: #3584e4;
          color: @cc-bg;
          text-shadow: none;
          padding: 0px;
          border-radius: 16px;
      }

      .close-button:hover {
          box-shadow: none;
          background: #62a0ea;
          transition: all 0.15s ease-in-out;
          border: none;
      }

      .widget-title {
          background: @noti-bg-darker;
          padding: 5px 10px;
          margin: 10px 10px 5px 10px;
          font-size: 16px;
          border-radius: 12px;
      }

      .widget-title > label {
          font-size: 16px;
      }

      .widget-title > button {
          font-size: 14px;
          color: @text-color;
          text-shadow: none;
          background: @cc-bg;
          box-shadow: none;
          border-radius: 8px;
      }

      .widget-title > button:hover {
          background: #3584e4;
          color: @cc-bg;
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
          padding: 5px;
          margin: 5px 10px 10px 10px;
          border-radius: 12px;
          background: @noti-bg-darker;
      }

      .widget-buttons-grid > flowbox > flowboxchild:hover {
          background: transparent;
      }

      .widget-buttons-grid > flowbox > flowboxchild > button {
          margin: 3px;
          background: @cc-bg;
          border-radius: 8px;
          color: @text-color;
      }

      .widget-buttons-grid > flowbox > flowboxchild > button:hover {
          background: #3584e4;
          color: @cc-bg;
      }
    '';
  };
}
