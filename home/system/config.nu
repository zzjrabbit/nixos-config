def flake_update [] {
    proxychains4 -q nix flake update
}

def nixos_rebuild [] {
    sudo nixos-rebuild switch --flake ~/nixos --impure --accept-flake-config
}

def zed [] {
    zeditor .
}

def devenv [] {
    nix develop -c $env.SHELL
}

$env.config.show_banner = false
