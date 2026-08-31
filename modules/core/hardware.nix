{ lib, modulesPath, inputs, ... }:

{
  imports = [
    (modulesPath + "/profiles/all-hardware.nix")
    (modulesPath + "/installer/scan/not-detected.nix")
  ];

  # Keep the portable installation bootable behind common SATA, NVMe, Intel
  # VMD/RST and USB storage controllers.  all-hardware.nix adds older drivers.
  boot.initrd.availableKernelModules = [
    "ahci"
    "nvme"
    "vmd"
    "xhci_pci"
    "usb_storage"
    "uas"
    "sd_mod"
  ];
  boot.initrd.kernelModules = [ ];
  boot.extraModulePackages = [ ];
  boot.supportedFilesystems = [ "ntfs" ];

  # Exposes pkgs.cachyosKernels while retaining the upstream-pinned package
  # set needed for the provider's binary cache.
  nixpkgs.overlays = [ inputs.nix-cachyos-kernel.overlays.pinned ];

  fileSystems."/" = {
    device = "none";
    fsType = "tmpfs";
    options = [ "defaults" "size=50%" "mode=755" ];
  };

  swapDevices = [ ];

  # Enables DHCP on each ethernet and wireless interface. In case of scripted networking
  # (the default) this is the recommended approach. When using systemd-networkd it's
  # still possible to use this option, but it's recommended to use it in conjunction
  # with explicit per-interface declarations with `networking.interfaces.<interface>.useDHCP`.
  networking = {
    useDHCP = lib.mkDefault true;
  };

  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";

  powerManagement.enable = true;
}
