# SwayNC notification daemon module
# This module configures the swaync notification system for Wayland compositors

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
      @define-color noti-bg #303030;
      @define-color noti-bg-darker #303030;
      @define-color noti-bg-hover rgb(48, 48, 51);
      @define-color noti-bg-focus rgba(48, 48, 51, 0.6);
      @define-color text-color #ffffff;
      @define-color text-color-disabled #949494;
      @define-color bg-selected #8FD0FF;

      * {
          font-family: FiraCode;
          font-weight: bold;
          box-shadow: none;
      }

      .control-center {
          background: @cc-bg;
          border: 2px solid #215d9c;
          border-radius: 12px;
      }

      .control-center-list {
          background: transparent
      }

      .control-center-list-placeholder {
          opacity: .5
      }

      .notification-row {
          outline: none;
      }

      .notification-group {
          outline: none;
      }

      .notification-group-headers {
          margin-bottom: 8px;
      }

      .notification-group-buttons {
          margin-bottom: 8px;
      }

      .notification {
          background: transparent;
          border-radius: 12px;
          border: 2px solid #215d9c;
      }

      .notification-background {
          margin: 2px 6px;
          padding: 0px;
      }

      .notification-content {
          background: @cc-bg;
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
          color: #ffffff;
          font-size: 13px;
          font-weight: normal;
          border: 1px solid @noti-border-color;
          background: #242424;
      }

      .notification-action:hover {
          color: #ffffff;
          background: #303030;
      }

      .notification-default-action:hover {
          color: #ffffff;
          background: #303030;
      }

      .close-button {
          background: #7FBFFF;
          color: @cc-bg;
          text-shadow: none;
          padding: 0px;
          border-radius: 16px;
      }

      .close-button:hover {
          box-shadow: none;
          background: #6F7FF0;
          transition: all .15s ease-in-out;
          border: none
      }

      .widget-title {
          color: #ffffff;
          background: @noti-bg-darker;
          padding: 5px 10px;
          margin: 10px 10px 5px 10px;
          font-size: 16px;
          border-radius: 12px;
      }

      .widget-title>button {
          font-size: 14px;
          color: @text-color;
          text-shadow: none;
          background: @cc-bg;
          box-shadow: none;
          border-radius: 8px;
      }

      .widget-title>button:hover {
          background: #7FBFFF;
          color: @cc-bg;
      }

      .widget-dnd {
          background: @noti-bg-darker;
          padding: 5px 10px;
          margin: 5px 10px 10px 10px;
          border-radius: 12px;
          font-size: large;
          color: #ffffff;
      }

      .widget-dnd>switch {
          border-radius: 12px;
          background: #424242;
      }

      .widget-dnd>switch:checked {
          background: #3584e4;
          border: 1px solid #7FD0FF;
      }

      .widget-dnd>switch slider {
          background: @cc-bg;
          border-radius: 12px
      }

      .widget-dnd>switch:checked slider {
          background: @cc-bg;
          border-radius: 12px
      }

      .widget-label {
          margin: 10px 10px 5px 10px;
      }

      .widget-label>label {
          font-size: 14px;
          color: @text-color;
      }

      .widget-mpris {
          margin-bottom: -20px;
      }

      .widget-mpris-player {
          margin: 8px 12px;
          padding-bottom: 8px;
          box-shadow: none;
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

      .widget-buttons-grid>flowbox>flowboxchild>button {
          margin: 3px;
          background: @cc-bg;
          border-radius: 8px;
          color: @text-color
      }

      .widget-buttons-grid>flowbox>flowboxchild>button:hover {
          background: #7FBFFF;
          color: @cc-bg;
      }

      .widget-menubar>box>.menu-button-bar>button {
          border: none;
          background: transparent
      }

      .topbar-buttons>button {
          border: none;
          background: transparent
      }
    '';
  };
}
