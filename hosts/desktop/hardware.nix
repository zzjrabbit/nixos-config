{ lib, config, pkgs, ... }:
{
  # This Skylake CPU supports x86_64-v3.  Keep it on the same pre-regression
  # CachyOS 7.1.5 BORE kernel as the laptop.
  boot.kernelPackages = pkgs.cachyosKernels.linuxPackages-cachyos-bore-x86_64-v3;
  hardware.cpu.intel.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
}
