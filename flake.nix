{
  description = "UEFIer's NixOS Configuration";

  nixConfig = {
    substituters = [
      "https://attic.xuyh0120.win/lantian"
      "https://cache.nixos.org"
      "https://cache.numtide.com"
      "https://mirrors.ustc.edu.cn/nix-channels/store"
	];

    trusted-public-keys = [
      "lantian:EeAUQ+W+6r7EtwnmYjeVwx5kOGEBpjlBfPlzGlTNvHc="
      "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
      "niks3.numtide.com-1:DTx8wZduET09hRmMtKdQDxNNthLQETkc/yaX7M4qK0g="
    ];
  };

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    # Keep this input independent from nixpkgs so its prebuilt kernels and
    # patches are evaluated against the revision they were built for.
    nix-cachyos-kernel.url = "github:xddxdd/nix-cachyos-kernel/e2c327cc00fd5243685fee69e90e4c7eb2f6e8ba";
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
    llm-agents.url = "github:numtide/llm-agents.nix";
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
        laptop = mkHost { name = "laptop"; };
        desktop = mkHost { name = "desktop"; };
      };
    };
}
