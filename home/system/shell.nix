{ ... }: {
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
        exec nu
    fi
  '';
}
