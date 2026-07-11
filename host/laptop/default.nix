{ pkgs, lib, config, ... }:
let
  magicbookThermalProfile = pkgs.writeShellScript "magicbook-thermal-profile" ''
    set -eu

    online=0
    if [ -r /sys/class/power_supply/ACAD/online ]; then
      online="$(cat /sys/class/power_supply/ACAD/online)"
    fi

    if [ "$online" = "1" ]; then
      exec ${pkgs.ryzenadj}/bin/ryzenadj \
        --max-performance \
        --stapm-limit=20000 \
        --fast-limit=25000 \
        --slow-limit=22000 \
        --tctl-temp=82
    fi

    exec ${pkgs.ryzenadj}/bin/ryzenadj \
      --power-saving \
      --stapm-limit=12000 \
      --fast-limit=15000 \
      --slow-limit=13000 \
      --tctl-temp=75
  '';
in {
  imports = [
    ../common.nix
  ];

  environment.systemPackages = [ pkgs.ryzenadj ];
  
  boot.postBootCommands = ''
    ${pkgs.ryzenadj}/bin/ryzenadj --set-uma-size=256 || true
  '';

  boot.kernelParams = [ "amdgpu.backlight=0" "acpi_backlight=none" ];
  boot.kernelModules = [ "kvm-amd" ];
  boot.kernel.sysctl = { "vm.swappiness" = 200; };

  hardware.cpu.amd.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;

  systemd.services.magicbook-thermal-profile = {
    description = "Apply Huawei MagicBook thermal limits";
    wantedBy = [ "multi-user.target" ];
    serviceConfig = {
      Type = "oneshot";
      ExecStart = magicbookThermalProfile;
    };
  };

  systemd.paths.magicbook-thermal-profile = {
    wantedBy = [ "multi-user.target" ];
    pathConfig.PathChanged = "/sys/class/power_supply/ACAD/online";
  };

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
