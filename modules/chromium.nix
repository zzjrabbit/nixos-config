{ ... }:

{
  # Stylix supplies BrowserThemeColor from the shared Event Horizon palette.
  stylix.targets.chromium.enable = true;

  # Force-install every provisioned browser extension through the system
  # policy so none of them depends on manual user confirmation.
  programs.chromium = {
    enable = true;
    extensions = [
      "pfnededegaaopdmhkdmcofjmoldfiped" # ZeroOmega
      "bpoadfkcbjbfhfodiogcnhhhpibjhbnh" # Immersive Translate
      "dhdgffkkebhmkfjojejmpbldmpobfkfo" # Tampermonkey
      "bgnkhhnnamicmpeenaelnjfhikgbkllg" # AdGuard AdBlocker
    ];
  };
}
