{ pkgs, config, ... }: let
  nvimPath = "${config.home.homeDirectory}/nixos/nvim";
in {
  home.packages = with pkgs; [
    neovim
  ];
  xdg.configFile."nvim".source = config.lib.file.mkOutOfStoreSymlink nvimPath;
}
