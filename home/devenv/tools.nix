{ pkgs, ... }:
{
  home.packages = with pkgs;[
    llvmPackages_latest.bintools-unwrapped
    
    rust-cbindgen
    
    tokei
    
    qemu_kvm
    
    xorriso
    
    rustup
  ];
}