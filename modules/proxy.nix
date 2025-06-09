{ ... }:
{
  programs.proxychains = {
    enable = true;
    proxies = {
      prx1 = {
        enable = true;
        type = "http";
        host = "127.0.0.1";
        port = 2080;
      };
    };
  };

  programs.nekoray = {
    enable = true;
    tunMode = {
      enable = true;
    };
  };
}
