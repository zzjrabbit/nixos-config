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
    openjdk21
  ];
}
