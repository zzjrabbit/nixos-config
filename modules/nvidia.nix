{ pkgs, ... }:

{
  hardware.nvidia = {
    open = true;
    modesetting.enable = true;
    nvidiaSettings = false;
  };

  services = {
    lact.enable = true;
    xserver.videoDrivers = ["nvidia"];
  };

  hardware.graphics.extraPackages = with pkgs; [
    nvidia-vaapi-driver
  ];
}
