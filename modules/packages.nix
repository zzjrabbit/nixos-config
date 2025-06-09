{ pkgs, ... }:
{
  programs.adb.enable = true;
  programs.niri.enable = true;
  programs.nm-applet.enable = true;

  environment.systemPackages = with pkgs; [
    vim
    wget
    waybar
    alacritty
    git
    xwayland-satellite
    scrcpy
    android-tools
    waypaper
    swaybg
    networkmanagerapplet
    hypridle
    polkit_gnome
    proxychains
    krb5
    linuxKernel.packages.linux_latest_libre.perf
    heaptrack
    greetd.tuigreet
    pavucontrol
  ];

  nixpkgs.config.allowUnfree = true;
}
