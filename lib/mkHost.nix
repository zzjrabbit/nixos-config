{ nixpkgs, inputs }:

{
  name,
  user ? "raca",
  extraModules ? [ ],
}:

nixpkgs.lib.nixosSystem {
  system = "x86_64-linux";

  specialArgs = {
    inherit inputs;
    hostName = name;
    userName = user;
  };

  modules = [
    ../modules
    ../hosts/${name}
    { networking.hostName = name; }
  ]
  ++ extraModules;
}
