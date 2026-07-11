{ config, ... }: {
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
        if [ -f "${config.sops.secrets."dpsk_api_key".path}" ]; then
          export DPSK_API_KEY="$(cat ${config.sops.secrets."dpsk_api_key".path})"
          export E_FLOW_API_KEY="$(cat ${config.sops.secrets."e_flow".path})"
        fi
        exec nu
    fi
  '';
}
