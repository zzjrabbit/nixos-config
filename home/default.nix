{ ... }:
{
  imports = [
    ./packages.nix

    ./apps/term.nix
    ./apps/firefox.nix
    ./apps/zed.nix
    ./apps/vbox.nix
    ./apps/nvim.nix

    ./desktop/fuzzel.nix
    ./desktop/niri.nix
    ./desktop/swaync.nix
    ./desktop/waybar.nix
    
    ./system/fcitx5.nix
    ./system/git.nix
    ./system/services.nix
    ./system/utils.nix
    ./system/theming.nix
    ./system/xdg.nix
    ./system/shell.nix
    ./system/persist.nix
  ];

  home.username = "raca";
  home.homeDirectory = "/home/raca";

  home.stateVersion = "24.11";
  programs.home-manager.enable = true;
}
