{ lib, config, ... }: {
  imports = [
    ../common.nix
  ];

  boot.kernelParams = [ "amdgpu.backlight=0" "acpi_backlight=none" ];
  boot.kernelModules = [ "kvm-amd" ];
  boot.kernel.sysctl = { "vm.swappiness" = 200; };

  hardware.cpu.amd.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;

  zramSwap = {
    enable = true;
    algorithm = "zstd";
    memoryPercent = 300;
  };
  
  fileSystems."/persist" = { 
    device = "/dev/disk/by-uuid/88aedad5-6e73-4152-8c6d-d794955447bd";
    neededForBoot = true;
    fsType = "btrfs";
    options = [ "subvol=@" "compress-force=zstd" ];
  };

  fileSystems."/persist/home" = { 
    device = "/dev/disk/by-uuid/88aedad5-6e73-4152-8c6d-d794955447bd";
    fsType = "btrfs";
    options = [ "subvol=@home" "compress-force=zstd" ];
  };

  fileSystems."/nix" = { 
    device = "/dev/disk/by-uuid/88aedad5-6e73-4152-8c6d-d794955447bd";
    fsType = "btrfs";
    options = [ "subvol=@nix" "noatime" "compress-force=zstd" ];
  };

  fileSystems."/boot" = { 
    device = "/dev/disk/by-uuid/81C9-2693";
    fsType = "vfat";
    options = [ "fmask=0022" "dmask=0022" ];
  };
}
