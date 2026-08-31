{ config, lib, pkgs, ... }:
{
  options.my.hardware.nvidia.enable =
    lib.mkEnableOption "the proprietary NVIDIA driver stack (Pascal or newer, LACT, VA-API)";

  config = lib.mkIf config.my.hardware.nvidia.enable {
    hardware.nvidia = {
      # GTX 1060 is Pascal: it needs the proprietary kernel module and is no
      # longer supported by the current 590+ driver series.  The maintained
      # 580 legacy branch also supports newer NVIDIA cards, making it the most
      # useful single branch for a portable desktop installation.
      open = false;
      branch = "legacy_580";
      modesetting.enable = true;
      nvidiaSettings = false;
    };

    hardware.graphics = {
      enable = true;
      enable32Bit = true;
      extraPackages = with pkgs; [
        nvidia-vaapi-driver
      ];
    };

    services = {
      lact.enable = true;
      # Keep the generic modesetting DDX available for Intel/AMD GPUs and for
      # systems whose display is connected to an integrated GPU.
      xserver.videoDrivers = [ "nvidia" "modesetting" ];
    };
  };
}
