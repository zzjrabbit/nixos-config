{ lib, config, pkgs, ... }:
{
  # 7.1.5 predates the amdgpu corruption regression.  BORE keeps this older
  # Raven/Picasso APU responsive, while x86_64-v3 is supported by Zen+.
  boot.kernelPackages = pkgs.cachyosKernels.linuxPackages-cachyos-bore-x86_64-v3;
  boot.kernelParams = [ "amdgpu.backlight=0" "acpi_backlight=none" ];
  boot.kernelModules = [ "kvm-amd" ];
  boot.kernel.sysctl = { "vm.swappiness" = 200; };

  hardware.cpu.amd.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;

  zramSwap = {
    enable = true;
    algorithm = "zstd";
    memoryPercent = 300;
  };
}
