{ lib, ... }:

let
  extensions = {
    "adguardadblocker@adguard.com" = "adguard-adblocker";
    "{446900e4-71c2-419f-a6a7-df9c091e268b}" = "bitwarden-password-manager";
    "suziwen1@gmail.com" = "zeroomega";
    "firefox@tampermonkey.net" = "tampermonkey";
    "{5efceaa7-f3a2-4e59-a54b-85319448e305}" = "immersive-translate";
  };
in
{
  programs.firefox = {
    enable = true;
    languagePacks = ["zh-CN"];

    profiles.default = {
      isDefault = true;
      search = {
        force = true;
        default = "google";
      };
    };

    policies = {
      ExtensionSettings = lib.mapAttrs
        (id: name: {
          installation_mode = "normal_installed";
          install_url = "https://addons.mozilla.org/firefox/downloads/latest/${name}/latest.xpi";
        })
        extensions;
    };
  };
}
