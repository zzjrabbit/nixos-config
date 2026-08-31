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

  # GRUB exposes these as recovery choices.  They make one portable system
  # recoverable on unsupported/quirky GPUs without editing the store from
  # another machine.
  specialisation = {
    nouveau.configuration = {
      system.nixos.tags = [ "nouveau" ];
      my.hardware.nvidia.enable = lib.mkForce false;
      services.xserver.videoDrivers = lib.mkForce [ "modesetting" ];
      boot.kernelParams = [ "nouveau.modeset=1" ];
    };

    console.configuration = {
      system.nixos.tags = [ "console" ];
      my.hardware.nvidia.enable = lib.mkForce false;
      boot.kernelParams = [ "nomodeset" ];
      services.greetd.enable = lib.mkForce false;
      services.displayManager.regreet.enable = lib.mkForce false;
      services.xserver.enable = lib.mkForce false;
      systemd.defaultUnit = lib.mkForce "multi-user.target";
    };
  };
}
