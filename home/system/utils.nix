{ pkgs, ... }:
{
  programs.fastfetch = {
    enable = true;
  };
  
  home.packages = with pkgs;[
    nautilus
    
    # archives
    zip
    xz
    unzip
    p7zip

    # utils
    ripgrep
    jq 
    yq-go 
    eza
    fzf
    udiskie

    # networking tools
    mtr 
    iperf3
    dnsutils
    ldns
    aria2
    socat
    nmap 
    ipcalc 

    cowsay
    file
    which
    tree
    gnused
    gnutar
    gawk
    zstd
    gnupg

    # nix related
    # it provides the command `nom` works just like `nix`
    # with more details log output
    nix-output-monitor

    btop

    sysstat
    lm_sensors
    ethtool
    pciutils
    usbutils
  ];
}
