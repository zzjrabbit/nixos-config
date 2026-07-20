{ inputs, pkgs, ... }:
let
  sopsAgeKeyFile = "/persist/home/raca/.config/sops/age/keys.txt";
  checkSopsAgeKey = pkgs.writeShellScript "check-sops-age-key" ''
    set -eu

    key=${sopsAgeKeyFile}
    if [ ! -f "$key" ]; then
      echo "Missing SOPS Age identity: $key" >&2
      exit 1
    fi

    mode="$(${pkgs.coreutils}/bin/stat -c %a "$key")"
    owner="$(${pkgs.coreutils}/bin/stat -c %U "$key")"
    if [ "$mode" != "600" ] || { [ "$owner" != "root" ] && [ "$owner" != "raca" ]; }; then
      echo "SOPS Age identity must be mode 0600 and owned by root or raca" >&2
      exit 1
    fi
  '';
in
{
  imports = [
    ./common_hw.nix
    inputs.home-manager.nixosModules.home-manager
    inputs.impermanence.nixosModules.impermanence
    inputs.sops-nix.nixosModules.sops
    inputs.stylix.nixosModules.stylix

    ../modules/persist.nix
    ../modules/packages.nix
    ../modules/services.nix
    ../modules/proxy.nix
    ../modules/snapper.nix
    ../modules/greetd.nix
    ../modules/niri.nix
    ../modules/chromium.nix
    ../modules/stylix.nix
  ];

  sops = {
    defaultSopsFile = ../secrets/dpsk_api_key.yaml;
    useSystemdActivation = true;
    age = {
      keyFile = sopsAgeKeyFile;
      sshKeyPaths = [ ];
    };
    secrets = {
      dpsk_api_key = {
        owner = "raca";
        group = "users";
        mode = "0400";
      };
      e_flow = {
        sopsFile = ../secrets/e_flow.yaml;
        owner = "raca";
        group = "users";
        mode = "0400";
      };
    };
  };

  systemd.services.sops-install-secrets.serviceConfig.ExecStartPre = checkSopsAgeKey;

  nixpkgs = {
    config.allowUnfree = true;
    overlays = [
      inputs.chinese-fonts-overlay.overlays.default
    ];
  };

  home-manager = {
    useGlobalPkgs = true;
    useUserPackages = true;
    extraSpecialArgs = { inherit inputs; };
    users.raca = import ../home;

    # Home Manager must be able to take ownership of pre-existing dotfiles on
    # the first activation.  Without this, one unmanaged file aborts the whole
    # activation and leaves niri/Waybar without their generated configuration.
    backupFileExtension = "hm-backup";
    overwriteBackup = true;
  };

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
      fcitx5.addons = with pkgs; [
        qt6Packages.fcitx5-chinese-addons
        fcitx5-gtk
      ];
    };
  };

  fonts = {
    packages = with pkgs; [
      foundertypePackages.fzheiti
      foundertypePackages.fzshusong
      foundertypePackages.fzfangsong
      foundertypePackages.fzkaiti

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

  nix.settings.experimental-features = [
    "nix-command"
    "flakes"
  ];

  nix.settings.trusted-users = [ "raca" ];

  nix.settings.substituters = [
    "https://niri.cachix.org"
    "https://cache.nixos.org"
    "https://mirrors.ustc.edu.cn/nix-channels/store"
  ];
  nix.settings.trusted-public-keys = [
    "hydra.nixos.org-1:CNHJZBh9K4tP3EKF6FkkgeVYsS3ohTl+oS0Qa8bezVs="
    "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
    "niri.cachix.org-1:Wv0OmO7PsuocRKzfDoJ3mulSl7Z6oezYhGhR+3W2964="
  ];

  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 1w";
  };

  nix.settings.auto-optimise-store = true;

  system.stateVersion = "26.11";
}
