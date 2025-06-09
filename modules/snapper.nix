{ config, lib, pkgs, ... }:

{
  services.snapper = {
    configs = {
      root = {
        SUBVOLUME = "/persist";
        ALLOW_GROUPS = [ "wheel" ];
        TIMELINE_CREATE = true;
        TIMELINE_CLEANUP = true;
        TIMELINE_LIMIT_HOURLY = 6;
        TIMELINE_LIMIT_DAILY = 3;
        TIMELINE_LIMIT_WEEKLY = 1;
        TIMELINE_LIMIT_MONTHLY = 1;
        TIMELINE_LIMIT_YEARLY = 0;
      };

      home = {
        SUBVOLUME = "/persist/home";
        ALLOW_GROUPS = [ "wheel" ];
        TIMELINE_CREATE = true;
        TIMELINE_CLEANUP = true;
        TIMELINE_LIMIT_HOURLY = 12;
        TIMELINE_LIMIT_DAILY = 7;
        TIMELINE_LIMIT_WEEKLY = 4;
        TIMELINE_LIMIT_MONTHLY = 2;
        TIMELINE_LIMIT_YEARLY = 0;
      };
    };
  };

  systemd.services.snapper-subvolumes = {
    script = lib.concatMapStringsSep "\n"
      (config: ''
        if [ ! -e "${config.SUBVOLUME}/.snapshots" ]; then
          btrfs subvolume create "${config.SUBVOLUME}/.snapshots"
        fi
      '')
      (lib.attrValues config.services.snapper.configs);

    serviceConfig.Type = "oneshot";
    path = with pkgs; [ btrfs-progs ];
    requiredBy = [ "snapper-timeline.service" ];
    before = [ "snapper-timeline.service" ];
    description = "Create .snapshots subvolumes for Snapper";
  };
}