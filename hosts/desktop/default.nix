{ lib, ... }:
{
  imports = [
    ./hardware.nix
    ./disks.nix
  ];

  # The desktop host is the NixOS To Go installation.  Use the standard
  # removable-media path so it can boot without machine-specific NVRAM.
  boot.loader = {
    efi.canTouchEfiVariables = lib.mkForce false;
    grub.efiInstallAsRemovable = true;
  };

  my = {
    desktop.enable = true;
    hardware.nvidia.enable = true;
  };
}
