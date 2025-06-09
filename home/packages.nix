{ pkgs, ... }:
{
  home.packages = with pkgs;[
    qq
    hmcl
    keepassxc
    libreoffice-fresh
    clapper
  ];
}
