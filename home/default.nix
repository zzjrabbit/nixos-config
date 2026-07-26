{ userName, ... }:
{
  imports = [
    ./packages.nix

    ./apps/term.nix
    ./apps/chromium.nix
    ./apps/zed.nix
    # ./apps/vbox.nix
    ./apps/nvim
    ./apps/vsc.nix
    ./apps/codex.nix

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

  home.username = userName;
  home.homeDirectory = "/home/${userName}";

  home.stateVersion = "26.11";
  programs.home-manager.enable = true;
}
