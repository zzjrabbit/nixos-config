{ config, inputs, pkgs, ... }:

let
  palette = import ./palette.nix { inherit config; };
in
{
  imports = [ inputs.nvf.homeManagerModules.default ];

  programs.nvf = {
    enable = true;
    settings = {
      imports = [
        (import ./options.nix { inherit pkgs; })
        ./lsp.nix
        (import ./plugins.nix { inherit pkgs palette; })
        (import ./theme.nix { inherit palette; })
        ./keymaps.nix
      ];
    };
  };
}
