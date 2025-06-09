{ pkgs, ... }:
{
  imports =
    [
      ./hardware.nix
    ];

  boot.loader = {
    efi.canTouchEfiVariables = true;

    grub = {
      enable = true;
      device = "nodev";
      efiSupport = true;
      useOSProber = true;
      configurationLimit = 10;
    };
  };

  networking.hostName = "raca";

  time.timeZone = "Asia/Shanghai";

  i18n = {
    defaultLocale = "zh_CN.UTF-8";
    inputMethod = {
      type = "fcitx5";
      enable = true;
      fcitx5.addons = with pkgs; [ fcitx5-chinese-addons fcitx5-gtk ];
    };
  };

  fonts = {
    packages = with pkgs; [
      noto-fonts
      noto-fonts-cjk-sans
      noto-fonts-cjk-serif
      hack-font
      jetbrains-mono
      nerd-fonts.fira-code
      nerd-fonts.sauce-code-pro
    ];
  };

  users.users.raca = {
    isNormalUser = true;
    extraGroups = [ "wheel" ];
    shell = pkgs.zsh;
    ignoreShellProgramCheck = true;
    hashedPasswordFile = "/persist/secret/raca";
    packages = with pkgs; [
      tree
    ];
  };
  
  users.mutableUsers = false;

  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  nix.settings.substituters = [
    "https://mirror.sjtu.edu.cn/nix-channels/store"
    "https://cache.nixos.org"
    "https://mirrors.ustc.edu.cn/nix-channels/store"
    "https://niri.cachix.org"
  ];

  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 1w";
  };

  nix.settings.auto-optimise-store = true;

  system.stateVersion = "24.11";

}
