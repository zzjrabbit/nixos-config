{ lib, config, ... }:
{
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
