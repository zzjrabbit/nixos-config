{ pkgs, ... }:
{
  home.packages = with pkgs;[
    qq
    hmcl
    keepassxc
    libreoffice-fresh
    clapper
    wine
    wine-staging
    wine-wayland
    luanti
    openjdk21
  ];
}
