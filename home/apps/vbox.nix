{ pkgs, ... }:
{
  home.packages = with pkgs; [
    virtualboxKvm
  ];
}