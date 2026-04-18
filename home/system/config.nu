def flake_update [] {
    proxychains4 -q nix flake update
}

def nixos_rebuild [host: string] {
    sudo nixos-rebuild switch --flake $"/home/raca/nixos#$host" --impure --accept-flake-config
}

def zed [] {
    zeditor .
}

def devenv [] {
    nix develop -c $env.SHELL
}

$env.config.show_banner = false
$env.ZED_ACCEPT_PREDICTION_URL = "https://localhost:4444/accept"
