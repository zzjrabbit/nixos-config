{ pkgs, userName, ... }:
{
  users.defaultUserShell = pkgs.dash;
  users.users.root.shell = pkgs.dash;
  users.users.${userName} = {
    isNormalUser = true;
    extraGroups = [ "wheel" ];
    useDefaultShell = true;
    ignoreShellProgramCheck = true;
    hashedPasswordFile = "/persist/secret/${userName}";
    packages = with pkgs; [
      tree
    ];
  };
  environment.systemPackages = [ pkgs.dash ];

  users.mutableUsers = false;

  system.stateVersion = "26.11";
}
