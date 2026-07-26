{ ... }:

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
  };
}
