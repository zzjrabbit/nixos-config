{ ... }:
{
  programs.git = {
    enable = true;
    signing.format = null;
    settings = {
      user = {
        name = "zzjrabbit";
        email = "239873059@qq.com";
      };
    };
  };
}