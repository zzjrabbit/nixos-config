{ ... }:
{
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
}
