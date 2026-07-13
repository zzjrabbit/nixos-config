{
  description = "UEFIer's NixOS Configuration";

  nixConfig = {
    substituters = [
      "https://cache.nixos.org"
      "https://niri.cachix.org"
      "https://mirrors.ustc.edu.cn/nix-channels/store"
	];

    trusted-public-keys = [
      "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
      "niri.cachix.org-1:Wv0OmO7PsuocRKzfDoJ3mulSl7Z6oezYhGhR+3W2964="
    ];
  };

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    niri.url = "github:sodiboo/niri-flake";
    impermanence.url = "github:nix-community/impermanence";
    chinese-fonts-overlay.url = "github:brsvh/chinese-fonts-overlay/main";
    rime-shuangpin-fuzhuma = {
      url = "github:gaboolic/rime-shuangpin-fuzhuma/1c4750ec9828361fecdee174dac38d26e20ce667";
      flake = false;
    };
  };

  outputs =
    inputs@{
      self,
      nixpkgs,
      ...
    }:
    let
      mkHost = import ./lib/mkHost.nix {
        inherit nixpkgs;
        inherit inputs;
      };
    in {
      nixosConfigurations = {
        laptop = mkHost "laptop" [];
        desktop = mkHost "desktop" [];
      };
    };
}
