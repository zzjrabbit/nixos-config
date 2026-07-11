def flake_update [] {
    proxychains4 -q nix flake update
}

def nixos_rebuild [host: string] {
    sudo nixos-rebuild switch --flake $"/home/raca/nixos#($host)" --impure --accept-flake-config
}

def nixos_reboot [host: string] {
    sudo nixos-rebuild boot --flake $"/home/raca/nixos#($host)" --impure --accept-flake-config
}

def check_pkgs [host: string] {
    nix build .#nixosConfigurations.($host).config.system.build.toplevel --dry-run --impure
}

def history_profiles [] {
    nix profile history --profile /nix/var/nix/profiles/system
}

def devenv [] {
    nix develop -c $env.SHELL
}

def do_os_gc [] {
    sudo nix profile wipe-history --older-than 7d --profile /nix/var/nix/profiles/system
    sudo nix-collect-garbage --delete-old
    nix-collect-garbage --delete-old
}

def zed [] {
    zeditor .
}

def nix_shell [package: string] {
    nix shell nixpkgs#($package)
}

$env.config.show_banner = false
