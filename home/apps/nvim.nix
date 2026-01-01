{ pkgs, config, ... }: let
  nvimPath = "${config.home.homeDirectory}/nixos/nvim";
in {
  home.packages = with pkgs; [
    neovim
    vimPlugins.telescope-fzf-native-nvim
  ];
  xdg.configFile."nvim".source = config.lib.file.mkOutOfStoreSymlink nvimPath;
}
