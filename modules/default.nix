{ ... }:
{
  imports = [
    ./core/boot.nix
    ./core/fonts.nix
    ./core/hardware.nix
    ./core/home-manager.nix
    ./core/locale.nix
    ./core/nix.nix
    ./core/packages.nix
    ./core/users.nix

    ./desktop

    ./hardware/magicbook.nix
    ./hardware/nvidia.nix

    ./services/persist.nix
    ./services/proxy.nix
    ./services/secrets.nix
    ./services/services.nix
    ./services/snapper.nix
  ];
}
