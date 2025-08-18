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
    linuxPackages_latest.perf
    heaptrack
    pavucontrol
    perf-tools
  ];

  nixpkgs.config.allowUnfree = true;
}
