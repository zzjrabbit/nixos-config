{ pkgs, ... }:
{
  home.packages = with pkgs;[
    qq
    hmcl
    keepassxc
    libreoffice-fresh
    vlc
    wine
    wine-staging
    wine-wayland
    openjdk21
    parted
    exfatprogs
    tokei
    wechat
  ];
}
