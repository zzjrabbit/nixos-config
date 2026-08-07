{ config, lib, pkgs, ... }:
{
  options.my.hardware.nvidia.enable =
    lib.mkEnableOption "the NVIDIA driver stack (open kernel module, lact, vaapi)";

  config = lib.mkIf config.my.hardware.nvidia.enable {
    hardware.nvidia = {
      # GTX 1060 (Pascal) predates NVIDIA's supported open kernel modules.
      open = false;
      modesetting.enable = true;
      nvidiaSettings = false;
    };

    services = {
      lact.enable = true;
      xserver.videoDrivers = [ "nvidia" ];
    };

    hardware.graphics.extraPackages = with pkgs; [
      nvidia-vaapi-driver
    ];
  };
}
