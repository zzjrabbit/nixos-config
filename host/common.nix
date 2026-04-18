{ inputs, pkgs, ... }:
{
  imports =
    [
      ./common_hw.nix
      inputs.niri.nixosModules.niri
      inputs.home-manager.nixosModules.home-manager
      inputs.nur.modules.nixos.default
      inputs.impermanence.nixosModules.impermanence
    
      ../modules/persist.nix
      ../modules/packages.nix
      ../modules/services.nix
      ../modules/proxy.nix
      ../modules/snapper.nix
  ];
  
  programs.niri.enable = true;
  programs.niri.package = pkgs.niri-unstable;
  systemd.user.services.niri-flake-polkit.enable = false;
  
  nixpkgs = {
    config.allowUnfree = true;
    overlays = [
      inputs.niri.overlays.niri
      inputs.chinese-fonts-overlay.overlays.default # 所有字体
    ];
  };
  
  home-manager.useGlobalPkgs = true;
  home-manager.useUserPackages = true;
  home-manager.extraSpecialArgs = { inherit inputs; };
  home-manager.users.raca = import ../home;

  boot.loader = {
    efi.canTouchEfiVariables = true;

    grub = {
      enable = true;
      device = "nodev";
      efiSupport = true;
      useOSProber = true;
      configurationLimit = 10;
      theme = pkgs.catppuccin-grub;
    };
  };

  networking.hostName = "raca";

  time.timeZone = "Asia/Shanghai";

  i18n = {
    defaultLocale = "zh_CN.UTF-8";
    inputMethod = {
      type = "fcitx5";
      enable = true;
      fcitx5.addons = with pkgs; [ qt6Packages.fcitx5-chinese-addons fcitx5-gtk ];
    };
  };

  fonts = {
    packages = with pkgs; [
      foundertypeFonts.FZHTK
      foundertypeFonts.FZSSK
      foundertypeFonts.FZFSK
      foundertypeFonts.FZKTK
      
      noto-fonts
      noto-fonts-cjk-sans
      noto-fonts-cjk-serif
      hack-font
      jetbrains-mono
      nerd-fonts.fira-code
      nerd-fonts.sauce-code-pro
      fira-code
    ];
  };

  users.defaultUserShell = pkgs.dash;
  users.users.root.shell = pkgs.dash;
  users.users.raca = {
    isNormalUser = true;
    extraGroups = [ "wheel" ];
    useDefaultShell = true;
    ignoreShellProgramCheck = true;
    hashedPasswordFile = "/persist/secret/raca";
    packages = with pkgs; [
      tree
    ];
  };
  environment.systemPackages = [ pkgs.dash ];

  users.mutableUsers = false;
  
  environment.sessionVariables.NIXOS_OZONE_WL = "1";

  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  nix.settings.trusted-users = [ "raca" ];

  nix.settings.substituters = [
    "https://mirror.sjtu.edu.cn/nix-channels/store"
    "https://mirrors.ustc.edu.cn/nix-channels/store"
    "https://mirrors.tuna.tsinghua.edu.cn/nix-channels/store"
    "https://niri.cachix.org"
  ];

  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 1w";
  };

  nix.settings.auto-optimise-store = true;

  # system.nixos-init.enable = true;
  # system.etc.overlay.enable = true;
  # services.userborn.enable = true;
  
  system.stateVersion = "25.11";
}
