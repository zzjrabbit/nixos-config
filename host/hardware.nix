{ config, lib, pkgs, modulesPath, ... }:

{
  imports = [
    (modulesPath + "/profiles/all-hardware.nix")
    (modulesPath + "/installer/scan/not-detected.nix")
  ];

  boot.initrd.availableKernelModules = [ "nvme" "xhci_pci" "usb_storage" "uas" "sd_mod" ];
  boot.initrd.kernelModules = [ ];
  boot.kernelModules = [ "kvm-amd" ];
  boot.extraModulePackages = [ ];
  boot.kernelPackages = pkgs.linuxPackages_latest;
  boot.kernelParams = [ "amdgpu.backlight=0" "acpi_backlight=none" ];

  fileSystems."/" = {
    device = "none";
    fsType = "tmpfs";
    options = [ "defaults" "size=25%" "mode=755" ];
  };
  
  fileSystems."/persist" = { 
    device = "/dev/disk/by-uuid/17ac20c6-200e-4faa-8a81-31743016d744";
    neededForBoot = true;
    fsType = "btrfs";
    options = [ "subvol=@" "compress=zstd" ];
  };

  fileSystems."/persist/home" = { 
    device = "/dev/disk/by-uuid/17ac20c6-200e-4faa-8a81-31743016d744";
    fsType = "btrfs";
    options = [ "subvol=@home" "compress=zstd" ];
  };

  fileSystems."/nix" = { 
    device = "/dev/disk/by-uuid/17ac20c6-200e-4faa-8a81-31743016d744";
    fsType = "btrfs";
    options = [ "subvol=@nix" "noatime" "compress=zstd" ];
  };

  fileSystems."/boot" = { 
    device = "/dev/disk/by-uuid/B9C7-CE6B";
    fsType = "vfat";
    options = [ "fmask=0022" "dmask=0022" ];
  };

  swapDevices = [ ];
  zramSwap = {
    enable = true;
    algorithm = "zstd";
    memoryPercent = 400;
  };

  # Enables DHCP on each ethernet and wireless interface. In case of scripted networking
  # (the default) this is the recommended approach. When using systemd-networkd it's
  # still possible to use this option, but it's recommended to use it in conjunction
  # with explicit per-interface declarations with `networking.interfaces.<interface>.useDHCP`.
  networking.useDHCP = lib.mkDefault true;
  # networking.interfaces.wlp2s0.useDHCP = lib.mkDefault true;

  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
  hardware.cpu.amd.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;

  powerManagement.enable = true;
}
