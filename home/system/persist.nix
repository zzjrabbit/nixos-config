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
		
	  ".fgfs"

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

      ".codex"
      
      ".config/cabal"
      ".cache/cabal"
      ".stack"
      
      ".local/share/hmcl"
      
      ".config/Code"
      ".vscode"

      ".config/microsoft-edge"
      ".cache/microsoft-edge"
      ".cache/Microsoft"
        
      ".config/sops"

      # System directories that may contain user data
      ".local/share/keyrings"
      ".local/share/mcfly"
      ".local/share/nix"
      ".local/share/zed"
      ".local/share/fcitx5/rime"
      ".var/app"
      ".local/share/flatpak"
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
