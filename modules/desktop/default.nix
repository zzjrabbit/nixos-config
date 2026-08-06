{ lib, ... }:
{
  imports = [
    ./niri.nix
    ./greetd.nix
    ./stylix.nix
    ./chromium.nix
  ];

  options.my.desktop.enable =
    lib.mkEnableOption "the graphical desktop stack (niri, greetd/regreet, stylix, chromium)";
}
