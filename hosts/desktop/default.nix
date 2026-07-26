{ ... }:
{
  imports = [
    ./hardware.nix
    ./disks.nix
  ];

  my = {
    desktop.enable = true;
    hardware.nvidia.enable = true;
  };
}
