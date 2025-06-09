{ pkgs, ... }:
{
  home.packages = with pkgs;[
    llvmPackages_latest.mlir
    llvmPackages_latest.libllvm
    llvmPackages_latest.libcxx
    llvmPackages_latest.stdenv
  ];
}