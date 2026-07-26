{ pkgs, ... }:
{
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
    krb5
    perf
    heaptrack
    pavucontrol
    perf-tools
    docker
    gtk4
  ];
}
