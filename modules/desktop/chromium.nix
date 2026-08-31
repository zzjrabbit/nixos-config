{ config, lib, ... }:
{
  config = lib.mkIf config.my.desktop.enable {
    # Stylix supplies BrowserThemeColor from the shared Event Horizon palette.
    stylix.targets.chromium.enable = true;

    # Force-install every provisioned browser extension through the system
    # policy so none of them depends on manual user confirmation.
    programs.chromium = {
      enable = true;

      # DSH uses a dedicated Chromium app profile. Disable Chromium's native
      # translation offer by policy so its bubble cannot reappear on startup.
      # The separately installed Immersive Translate extension remains usable
      # in the normal browser profile.
      extraOpts.TranslateEnabled = false;

      extensions = [
        "pfnededegaaopdmhkdmcofjmoldfiped" # ZeroOmega
        "bpoadfkcbjbfhfodiogcnhhhpibjhbnh" # Immersive Translate
        "dhdgffkkebhmkfjojejmpbldmpobfkfo" # Tampermonkey
        "bgnkhhnnamicmpeenaelnjfhikgbkllg" # AdGuard AdBlocker
      ];
    };
  };
}
