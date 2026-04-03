{
  description = "UEFIer's NixOS Configuration";

  nixConfig = {
    substituters = [
      "https://cache.nixos.org"
      "https://niri.cachix.org"
    ];

    trusted-public-keys = [
      "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
      "niri.cachix.org-1:Wv0OmO7PsuocRKzfDoJ3mulSl7Z6oezYhGhR+3W2964="
    ];
  };

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable-small";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    niri.url = "github:sodiboo/niri-flake";
    nur.url = "github:nix-community/NUR";
    impermanence.url = "github:nix-community/impermanence";
    chinese-fonts-overlay.url = "github:brsvh/chinese-fonts-overlay/main";
  };

  outputs =
    inputs@{
      self,
      nixpkgs,
      home-manager,
      niri,
      nur,
      impermanence,
      chinese-fonts-overlay,
      ...
    }:
    {
      nixosConfigurations.raca = nixpkgs.lib.nixosSystem {
        specialArgs = { inherit inputs; };
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
              systemd.user.services.niri-flake-polkit.enable = false;
            }
          )

          (
            { pkgs, ... }:
            {
              nixpkgs = {
                config.allowUnfree = true;
                overlays = [
                  inputs.chinese-fonts-overlay.overlays.default # 所有字体
                ];
              };
              fonts.packages = with pkgs; [
                foundertypeFonts.FZHTK
                foundertypeFonts.FZSSK
                foundertypeFonts.FZFSK
                foundertypeFonts.FZKTK
              ];
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
