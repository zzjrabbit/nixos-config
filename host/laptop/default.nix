{ pkgs, lib, config, ... }:
let
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
        user_id="$(id -u raca)" || return 0
        bus="/run/user/$user_id/bus"

        [ -S "$bus" ] || return 0
        runuser -u raca -- env \
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
  imports = [
    ../common.nix
  ];

  environment.systemPackages = [
    magicbookPower
    pkgs.ryzenadj
  ];

  boot.postBootCommands = ''
    ${pkgs.ryzenadj}/bin/ryzenadj --set-uma-size=256 || true
  '';

  boot.kernelParams = [ "amdgpu.backlight=0" "acpi_backlight=none" ];
  boot.kernelModules = [ "kvm-amd" ];
  boot.kernel.sysctl = { "vm.swappiness" = 200; };

  hardware.cpu.amd.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;

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

  zramSwap = {
    enable = true;
    algorithm = "zstd";
    memoryPercent = 300;
  };

  fileSystems."/persist" = {
    device = "/dev/disk/by-uuid/88aedad5-6e73-4152-8c6d-d794955447bd";
    neededForBoot = true;
    fsType = "btrfs";
    options = [ "subvol=@" "compress-force=zstd" ];
  };

  fileSystems."/persist/home" = {
    device = "/dev/disk/by-uuid/88aedad5-6e73-4152-8c6d-d794955447bd";
    fsType = "btrfs";
    options = [ "subvol=@home" "compress-force=zstd" ];
  };

  fileSystems."/nix" = {
    device = "/dev/disk/by-uuid/88aedad5-6e73-4152-8c6d-d794955447bd";
    fsType = "btrfs";
    options = [ "subvol=@nix" "noatime" "compress-force=zstd" ];
  };

  fileSystems."/boot" = {
    device = "/dev/disk/by-uuid/81C9-2693";
    fsType = "vfat";
    options = [ "fmask=0022" "dmask=0022" ];
  };
}
