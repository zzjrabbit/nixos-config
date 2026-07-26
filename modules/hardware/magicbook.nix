{ config, lib, pkgs, userName, ... }:
let
  cfg = config.my.hardware.magicbook;

  magicbookPower = pkgs.writeShellApplication {
    name = "magicbook-power";
    runtimeInputs = [
      pkgs.coreutils
      pkgs.libnotify
      pkgs.ryzenadj
      pkgs.util-linux
    ];
    text = ''
      set -eu

      notify_osd() {
        summary="$1"
        body="$2"
        urgency="''${3:-normal}"
        user_id="$(id -u ${userName})" || return 0
        bus="/run/user/$user_id/bus"

        [ -S "$bus" ] || return 0
        runuser -u ${userName} -- env \
          DBUS_SESSION_BUS_ADDRESS="unix:path=$bus" \
          notify-send \
            --app-name="Huawei OSD" \
            --urgency="$urgency" \
            --expire-time=1800 \
            "$summary" "$body" || true
      }

      online=0
      if [ -r /sys/class/power_supply/ACAD/online ]; then
        online="$(cat /sys/class/power_supply/ACAD/online)"
      fi

      profile="''${1:-auto}"
      show_osd="''${2:-false}"
      if [ "$profile" = "auto" ]; then
        if [ "$online" = "1" ]; then
          profile=balanced
        else
          profile=powersave
        fi
      fi

      echo "Applying MagicBook power profile: $profile (AC online: $online)"

      case "$profile" in
        rejected)
          notify_osd "无法启用性能模式" "请连接电源并确认电量充足" critical
          exit 1
          ;;
        performance)
          if [ "$online" != "1" ]; then
            echo "Performance mode requires AC power" >&2
            [ "$show_osd" != "true" ] || \
              notify_osd "无法启用性能模式" "请连接电源并确认电量充足" critical
            exit 1
          fi
          ryzenadj \
            --stapm-limit=20000 \
            --fast-limit=25000 \
            --slow-limit=22000 \
            --tctl-temp=82
          [ "$show_osd" != "true" ] || \
            notify_osd "电源模式" "性能"
          ;;
        balanced)
          ryzenadj \
            --stapm-limit=15000 \
            --fast-limit=20000 \
            --slow-limit=18000 \
            --tctl-temp=80
          [ "$show_osd" != "true" ] || \
            notify_osd "电源模式" "平衡"
          ;;
        powersave)
          ryzenadj \
            --stapm-limit=12000 \
            --fast-limit=15000 \
            --slow-limit=13000 \
            --tctl-temp=75
          [ "$show_osd" != "true" ] || \
            notify_osd "电源模式" "省电"
          ;;
        *)
          echo "Usage: magicbook-power {auto|powersave|balanced|performance|rejected} [true]" >&2
          exit 2
          ;;
      esac
    '';
  };

  magicbookChargeThresholds = pkgs.writeShellScript "magicbook-charge-thresholds" ''
    set -eu
    printf '65 70\n' > /sys/devices/platform/huawei-wmi/charge_control_thresholds
  '';

  magicbookPowerEvents = pkgs.writeShellApplication {
    name = "magicbook-power-events";
    runtimeInputs = [ pkgs.systemd ];
    text = ''
      journalctl --dmesg --follow --lines=0 --output=cat |
        while IFS= read -r line; do
          case "$line" in
            *"Unknown key pressed, code: 0x02a0")
              ${lib.getExe magicbookPower} balanced true || true
              ;;
            *"Unknown key pressed, code: 0x02a1")
              ${lib.getExe magicbookPower} performance true || true
              ;;
            *"Unknown key pressed, code: 0x02a6")
              ${lib.getExe magicbookPower} rejected true || true
              ;;
          esac
        done
    '';
  };
in
{
  options.my.hardware.magicbook.enable =
    lib.mkEnableOption "Huawei MagicBook power management (ryzenadj profiles, charge thresholds, firmware power-mode keys)";

  config = lib.mkIf cfg.enable {
    environment.systemPackages = [
      magicbookPower
      pkgs.ryzenadj
    ];

    boot.postBootCommands = ''
      ${pkgs.ryzenadj}/bin/ryzenadj --set-uma-size=256 || true
    '';

    systemd.services.magicbook-power = {
      description = "Apply Huawei MagicBook power limits";
      wantedBy = [ "multi-user.target" ];
      serviceConfig = {
        Type = "oneshot";
        ExecStart = "${lib.getExe magicbookPower} auto";
      };
    };

    systemd.paths.magicbook-power = {
      wantedBy = [ "multi-user.target" ];
      pathConfig.PathChanged = "/sys/class/power_supply/ACAD/online";
    };

    systemd.services.magicbook-charge-thresholds = {
      description = "Set Huawei MagicBook battery charge thresholds";
      wantedBy = [ "multi-user.target" ];
      unitConfig.ConditionPathExists = "/sys/devices/platform/huawei-wmi/charge_control_thresholds";
      serviceConfig = {
        Type = "oneshot";
        ExecStart = magicbookChargeThresholds;
      };
    };

    systemd.services.magicbook-power-events = {
      description = "Handle Huawei MagicBook firmware power-mode events";
      wantedBy = [ "multi-user.target" ];
      after = [ "systemd-journald.service" ];
      serviceConfig = {
        ExecStart = lib.getExe magicbookPowerEvents;
        Restart = "always";
        RestartSec = 1;
      };
    };
  };
}
