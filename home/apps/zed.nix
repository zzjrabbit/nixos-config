# Zed editor configuration module
# This module configures the Zed code editor

{ ... }:

{
  programs.zed-editor = {
    enable = true;
    extensions = [
      "nix"
      "fleet-themes"
      "bearded-icon-theme"
    ];
    userKeymaps = [
      {
        context = "Workspace";
        bindings = {
          ctrl-shift-t = "workspace::NewTerminal";
        };
      }
    ];
    userSettings = {
      theme = {
        mode = "system";
        light = "One Light";
        dark = "Fleet Dark";
      };
      terminal = { dock = "bottom"; };
      icon_theme = "Bearded Icon Theme";
      agent = {
        default_model = {
          provider = "zed.dev";
          model = "claude-sonnet-4-thinking-latest";
        };
        version = "2";
        default_profile = "write";
        always_allow_tool_actions = true;
        stream_edits = true;
      };
      buffer_line_height = { custom = 1.35; };
      ui_font_size = 18;
      buffer_font_size = 18;
      ui_font_family = "Fira Code";
      buffer_font_family = "Fira Code";
      minimap = { show = "auto"; thumb = "hover"; };

      autosave = {
        after_delay = {
          milliseconds = 0;
        };
      };
    };
  };
}
