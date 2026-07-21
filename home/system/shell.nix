{ lib, osConfig, ... }:
let
  secretExports = lib.concatStringsSep "\n" (lib.mapAttrsToList
    (name: secret:
      let
        environmentName = lib.toUpper name;
      in ''
        if [ -r "${secret.path}" ]; then
          export ${environmentName}="$(cat ${lib.escapeShellArg secret.path})"
        fi
      '')
    osConfig.sops.secrets);
in {
  programs.nushell = {
    enable = true;
    extraConfig = builtins.readFile ./config.nu;
  };
  home.file.".profile".text = ''
    export VTERM='alacritty'
    export ENV='$HOME/.config/dashrc'
  '';
  home.file.".config/dashrc".text = ''
    if ! [ "$TERM" = "dumb" ]; then
        # Disable C-s freezing the terminal
        stty -ixon
        ${secretExports}
        exec nu
    fi
  '';
}
