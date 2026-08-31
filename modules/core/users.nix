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

  # Both root and the normal user use dash as their login shell.  Keep it in
  # /etc/shells so sudo/pkexec do not reject privilege escalation.
  environment.shells = [ pkgs.dash ];

  system.stateVersion = "26.11";
}
