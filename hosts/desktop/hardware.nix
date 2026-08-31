{ lib, config, pkgs, ... }:
{
  # This installation is intended to move between desktop PCs.  The stock
  # kernel is built for baseline x86_64 and receives the broadest in-tree
  # hardware and out-of-tree NVIDIA testing.  Do not use a CPU-specific v3
  # CachyOS kernel here: it can fail before the initrd on older machines.
  boot.kernelPackages = pkgs.linuxPackages;

  # Shipping both microcode families is safe; the kernel applies only the one
  # matching the CPU in the machine currently booting this installation.
  hardware.cpu = {
    amd.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
    intel.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
  };
}
