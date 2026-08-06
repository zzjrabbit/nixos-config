{ config, pkgs, ... }:

let
  # foot expects RGB values without the leading '#'.
  colors = config.lib.stylix.colors;
  zellijColors = config.lib.stylix.colors.withHashtag;
in
{
  programs.foot = {
    enable = true;
    settings = {
      main = {
        # Keep the existing TERM value for broad terminfo compatibility.
        term = "xterm-256color";
        shell = "dash";
        # Niri clips the window to its rounded geometry, so keep glyphs and
        # the cursor away from the clipped corners.
        pad = "14x12";
        # Copy selections to both Wayland clipboard targets.
        selection-target = "both";
      };
      scrollback = {
        lines = 10000;
        multiplier = 5;
      };
      mouse.hide-when-typing = "yes";
      # Stylix supplies the full palette; use the desktop accent for a
      # clearly visible text selection.
      "colors-dark" = {
        selection-background = colors.base0D;
        selection-foreground = colors.base00;
      };
    };
  };

  programs.zellij = {
    enable = true;
    themes."event-horizon" = {
      themes.default = with zellijColors; {
        # Keep the chrome dark and quiet; reserve cyan for the active tab and
        # use the remaining accents only for status and emphasis.
        text_unselected = {
          base = base05;
          background = base00;
          emphasis_0 = base0C;
          emphasis_1 = base0C;
          emphasis_2 = base0B;
          emphasis_3 = base0A;
        };
        text_selected = {
          base = base07;
          background = base02;
          emphasis_0 = base0C;
          emphasis_1 = base0C;
          emphasis_2 = base0B;
          emphasis_3 = base0D;
        };
        ribbon_selected = {
          base = base0C;
          background = base01;
          emphasis_0 = base0D;
          emphasis_1 = base0C;
          emphasis_2 = base0B;
          emphasis_3 = base0A;
        };
        ribbon_unselected = {
          base = base04;
          background = base00;
          emphasis_0 = base03;
          emphasis_1 = base0C;
          emphasis_2 = base0D;
          emphasis_3 = base05;
        };
        table_title = {
          base = base0C;
          background = base00;
          emphasis_0 = base0D;
          emphasis_1 = base0C;
          emphasis_2 = base0B;
          emphasis_3 = base0A;
        };
        table_cell_selected = {
          base = base07;
          background = base02;
          emphasis_0 = base0C;
          emphasis_1 = base0C;
          emphasis_2 = base0B;
          emphasis_3 = base0D;
        };
        table_cell_unselected = {
          base = base05;
          background = base00;
          emphasis_0 = base0C;
          emphasis_1 = base0C;
          emphasis_2 = base0D;
          emphasis_3 = base0A;
        };
        list_selected = {
          base = base07;
          background = base02;
          emphasis_0 = base0C;
          emphasis_1 = base0C;
          emphasis_2 = base0B;
          emphasis_3 = base0D;
        };
        list_unselected = {
          base = base05;
          background = base00;
          emphasis_0 = base0C;
          emphasis_1 = base0C;
          emphasis_2 = base0D;
          emphasis_3 = base0A;
        };
        frame_selected = {
          base = base0C;
          background = base00;
          emphasis_0 = base0C;
          emphasis_1 = base0D;
          emphasis_2 = base0B;
          emphasis_3 = base0A;
        };
        frame_highlight = {
          base = base0D;
          background = base00;
          emphasis_0 = base0C;
          emphasis_1 = base0B;
          emphasis_2 = base0A;
          emphasis_3 = base09;
        };
        exit_code_success = {
          base = base0B;
          background = base00;
          emphasis_0 = base0C;
          emphasis_1 = base01;
          emphasis_2 = base0F;
          emphasis_3 = base0D;
        };
        exit_code_error = {
          base = base08;
          background = base00;
          emphasis_0 = base0A;
          emphasis_1 = base00;
          emphasis_2 = base00;
          emphasis_3 = base00;
        };
        multiplayer_user_colors = {
          player_1 = base0C;
          player_2 = base0D;
          player_3 = base0C;
          player_4 = base0A;
          player_5 = base0B;
          player_6 = base0E;
          player_7 = base08;
          player_8 = base09;
          player_9 = base0F;
          player_10 = base06;
        };
      };
    };
    settings = {
      theme = "event-horizon";
      # Always resolve the theme from the Home Manager-managed directory.
      # This avoids accidentally picking up a theme from another config dir.
      theme_dir = "${config.xdg.configHome}/zellij/themes";
      # A theme is loaded when a session/server is created.  Do not resurrect
      # serialized sessions with the old theme after a Home Manager switch.
      session_serialization = false;
      default_layout = "compact";
      pane_frames = false;
      simplified_ui = true;
      mouse_mode = true;
      copy_on_select = true;
      copy_clipboard = "system";
      copy_command = "${pkgs.wl-clipboard}/bin/wl-copy";
      scroll_buffer_size = 10000;
    };
  };

  home.packages = [ pkgs.wl-clipboard ];
}
