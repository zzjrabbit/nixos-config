{
  description = "UEFIer's NixOS Configuration";

  nixConfig = {
    substituters = [
      "https://cache.nixos.org"
      "https://cache.numtide.com"
      "https://mirrors.ustc.edu.cn/nix-channels/store"
	];

    trusted-public-keys = [
      "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
      "niks3.numtide.com-1:DTx8wZduET09hRmMtKdQDxNNthLQETkc/yaX7M4qK0g="
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
    stylix = {
      url = "github:nix-community/stylix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    impermanence.url = "github:nix-community/impermanence";
    chinese-fonts-overlay.url = "github:brsvh/chinese-fonts-overlay/main";
    nvf = {
      url = "github:NotAShelf/nvf";
      inputs.nixpkgs.follows = "nixpkgs";
    };
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
