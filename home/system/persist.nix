{ inputs, ... }:

{
  imports = [
    inputs.impermanence.homeManagerModules.impermanence
  ];

  home.persistence."/persist" = {
    hideMounts = true;

    directories = [
      # User directories
      "Downloads"
      "Music"
      "Pictures"
      "Documents"
      "Videos"
      "Projects"
      
      {
        directory = ".ssh";
        mode = "0700";
      }
      
      "code"
      "nixos"
      
      ".cargo"
      ".rustup"
      ".java"
      ".xmake"
      ".zplug"
      ".zsh"
      "zsh-nix-shell"

      # Application data
      ".mozilla"
      ".config/QQ"
      ".minecraft"

      # Cache directories
      ".cache/nix"
      ".cache/keepassxc"
      
      ".config/nekoray"
      
      ".config/nvim"
      ".cache/nvim"
      ".local/share/nvim"
      
      ".local/share/hmcl"
      
      ".config/microsoft-edge"
      
      # System directories that may contain user data
      ".local/share/keyrings"
      ".local/share/mcfly"
      ".local/share/nix"
      ".local/share/zed"
    ];

    files = [
      # Shell configuration
      ".zsh_history"
      ".p10k.zsh"
      ".zshenv"

      # Cache files
      ".cache/fuzzel"
      
      ".hmcl.json"
      
      "密码.kdbx"
    ];
  };
}
