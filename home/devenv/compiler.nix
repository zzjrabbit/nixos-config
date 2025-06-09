{ pkgs, ... }:
{
  home.packages = with pkgs;[
    llvmPackages_latest.clang-unwrapped
    
    gcc15
    
    zig
    
    python314
  ];
}