{ ... }:
{
  imports = [
    ./hardware.nix
    ./disks.nix
  ];

  my = {
    desktop.enable = true;
    hardware.magicbook.enable = true;
  };
}
