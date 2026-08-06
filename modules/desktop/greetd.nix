{ config, lib, ... }:
{
  config = lib.mkIf config.my.desktop.enable {
    # ReGreet's NixOS module configures greetd with a Cage compositor and
    # launches ReGreet as the default session.
    services.displayManager.regreet = {
      enable = true;

      # ReGreet stores the last user/session in /var/lib/regreet/state.toml.
      # Reuse it on the next login, equivalent to tuigreet's remember flags.
      settings.skip_selection = true;
    };
  };
}
