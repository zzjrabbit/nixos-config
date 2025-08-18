# Zed editor configuration module
# This module configures the Zed code editor

{ pkgs, ... }:

{
  home.packages = with pkgs;[
    nixd
    nil
  ];
  
  programs.zed-editor = {
    enable = true;
    package = pkgs.zed-editor-fhs;
    
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
      terminal = {
	  	dock = "bottom";
		font_family = "Fira Code";
	  };
      icon_theme = "Bearded Icon Theme";
      agent = {
        default_model = {
          provider = "zed.dev";
          model = "claude-sonnet-4-thinking-latest";
        };
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
      
      lsp = {
        rust-analyzer = {
          binary = {
            path = "/home/raca/.rustup/toolchains/nightly-x86_64-unknown-linux-gnu/bin/rust-analyzer";
            arguments = [ ];
          };
        };
      };
    };
  };
}
