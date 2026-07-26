{ ... }:
{
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
