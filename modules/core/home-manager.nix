{ inputs, userName, ... }:
{
  imports = [ inputs.home-manager.nixosModules.home-manager ];

  home-manager = {
    useGlobalPkgs = true;
    useUserPackages = true;
    extraSpecialArgs = { inherit inputs userName; };
    users.${userName} = import ../../home;

    # Home Manager must be able to take ownership of pre-existing dotfiles on
    # the first activation.  Without this, one unmanaged file aborts the whole
    # activation and leaves niri/Waybar without their generated configuration.
    backupFileExtension = "hm-backup";
    overwriteBackup = true;
  };
}
