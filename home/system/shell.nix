{ osConfig, ... }:
let
  dpskApiKey = osConfig.sops.secrets.dpsk_api_key.path;
  eFlowApiKey = osConfig.sops.secrets.e_flow.path;
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
        if [ -r "${dpskApiKey}" ] && [ -r "${eFlowApiKey}" ]; then
          export DPSK_API_KEY="$(cat ${dpskApiKey})"
          export E_FLOW_API_KEY="$(cat ${eFlowApiKey})"
        fi
        exec nu
    fi
  '';
}
