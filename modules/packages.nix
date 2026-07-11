{ pkgs, ... }:
{
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
    krb5
    perf
    heaptrack
    pavucontrol
    perf-tools
    docker
    android-tools
	gtk4
  ];

  nixpkgs.config.allowUnfree = true;
}
