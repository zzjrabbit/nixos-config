{
  description = "UEFIer's NixOS Configuration";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    niri.url = "github:sodiboo/niri-flake";
    nur.url = "github:nix-community/NUR";
    impermanence.url = "github:nix-community/impermanence/home-manager-v2";
  };

  outputs =
    inputs@{
      self,
      nixpkgs,
      home-manager,
      niri,
      nur,
      impermanence,
      ...
    }:
    {
      nixosConfigurations.raca = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [
          niri.nixosModules.niri
          home-manager.nixosModules.home-manager
          nur.modules.nixos.default
          impermanence.nixosModules.impermanence

          ./host

          ./modules/persist.nix
          ./modules/packages.nix
          ./modules/services.nix
          ./modules/proxy.nix
          ./modules/snapper.nix
          (
            { pkgs, ... }:
            {
              programs.niri.enable = true;
              nixpkgs.overlays = [ inputs.niri.overlays.niri ];
              programs.niri.package = pkgs.niri-unstable;
            }
          )

          {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.extraSpecialArgs = { inherit inputs; };
            home-manager.users.raca = import ./home;
          }
        ];
      };
    };
}
