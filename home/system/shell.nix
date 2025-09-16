{ config, ... }:

{ 
  programs.zsh = {
    enable = true;
    enableCompletion = true;
    syntaxHighlighting = {
      enable = true;
    };
    
    shellAliases = {};
    history.path = "/persist/home/raca/.zsh_history";
    
    initContent = ''
      source ~/.p10k.zsh
    '';
    
    plugins = [
      {
        name = "p10k";
        src = config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/.p10k.zsh";
      }
      {
        name = "zsh-nix-shell";
        src = config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/zsh-nix-shell/nix-shell.plugin.zsh";
      }
    ];
    
    zplug = {
      enable = true;
      plugins = [
        { name = "zsh-users/zsh-autosuggestions"; } # Simple plugin installation
        { name = "romkatv/powerlevel10k"; tags = [ "as:theme" "depth:1" ]; } # Installations with additional options. For the list of options, please refer to Zplug README.
      ];
    };
  };
}