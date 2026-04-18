{ nixpkgs, inputs }:

name:
extraModules:

nixpkgs.lib.nixosSystem {
  system = "x86_64-linux";

  specialArgs = {
    inherit inputs;
  };

  modules =
    [
      ../host/${name}
    ]
    ++ extraModules;
}
