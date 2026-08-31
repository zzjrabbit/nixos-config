{ pkgs, ... }:
{
  environment.systemPackages = with pkgs; [
    vim
    wget
    waybar
    foot
    git
    xwayland-satellite
    scrcpy
    android-tools
    waypaper
    swaybg
    networkmanagerapplet
    hypridle
    krb5
    perf
    heaptrack
    pavucontrol
    perf-tools
    docker
    gtk4
  ];
}
