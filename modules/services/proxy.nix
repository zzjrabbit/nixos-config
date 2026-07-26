{ config, lib, ... }:
{
  options.my.proxy.enable = lib.mkEnableOption "proxychains and throne (TUN mode)" // {
    default = true;
  };

  config = lib.mkIf config.my.proxy.enable {
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

    programs.throne = {
      enable = true;
      tunMode = {
        enable = true;
      };
    };
  };
}
