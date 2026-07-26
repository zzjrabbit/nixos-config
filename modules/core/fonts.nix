{ pkgs, ... }:
{
  fonts = {
    packages = with pkgs; [
      foundertypePackages.fzheiti
      foundertypePackages.fzshusong
      foundertypePackages.fzfangsong
      foundertypePackages.fzkaiti

      noto-fonts
      noto-fonts-cjk-sans
      noto-fonts-cjk-serif
      hack-font
      jetbrains-mono
      nerd-fonts.fira-code
      nerd-fonts.sauce-code-pro
      fira-code
    ];
  };
}
