{ ... }:

{
  xdg = {
    enable = true;
    mimeApps = {
      enable = true;
      defaultApplications = {
        "inode/directory" = "nautilus.desktop";
      };
    };
    configFile = {
      "xfce4/helpers.rc".text = ''
        TerminalEmulator=alacritty
      '';
    };
  };
}
