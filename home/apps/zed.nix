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
      terminal = {
        shell = {
          program = "dash";
        };
        dock = "bottom";
      };
      icon_theme = "Bearded Icon Theme";
      buffer_line_height = { custom = 1.55; };
      ui_font_weight = 600;
      buffer_font_weight = 800;
      minimap = { show = "auto"; thumb = "hover"; };
      
      project_panel = {
        dock = "left";
      };
      agent = {
        dock = "right";
        sidebar_side = "right";
      };
      git_panel = {
        dock = "left";
      };
      collaboration = {
        dock = "right";
      };
      
      cli_default_open_behavior = "new_window";

      colorize_brackets = true;
      
      inlay_hints = {
        enabled = true;
        show_background = true;
      };

      autosave = {
        after_delay = {
          milliseconds = 0;
        };
      };
      
      lsp = {
        rust-analyzer = {
          binary = {
            path = "${pkgs.rust-analyzer}/bin/rust-analyzer";
            arguments = [ ];
          };
        };
      };
    };
  };
  
  home.file.".config/zed/snippets/haskell.json".source = ./haskell.json;
}
