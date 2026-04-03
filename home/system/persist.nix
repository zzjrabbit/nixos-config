{ ... }:

{
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
      ".elan"
      ".java"
      ".xmake"
      ".nix"

      # Application data
      ".mozilla"
      ".config/QQ"
      ".minecraft"
      ".minetest"
      ".mcreator"
      ".config/JetBrains"

      # Cache directories
      ".cache/nix"
      ".cache/keepassxc"
      
      ".config/Throne"
      
      ".cache/nvim"
      ".local/share/nvim"
      
      ".local/share/hmcl"
      
      ".config/Code"
      ".vscode"

      ".config/microsoft-edge"
      ".cache/microsoft-edge"
      ".cache/Microsoft"
      
      # System directories that may contain user data
      ".local/share/keyrings"
      ".local/share/mcfly"
      ".local/share/nix"
      ".local/share/zed"
      ".local/share/fcitx5/rime"
    ];

    files = [
      # Cache files
      ".cache/fuzzel"

      ".config/nushell/history.txt"

      ".hmcl.json"
      
      ".wakatime.cfg"
      
      "密码.kdbx"
    ];
  };
}
