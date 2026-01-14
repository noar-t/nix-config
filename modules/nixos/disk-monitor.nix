{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.services.disk-monitor;
  ntfy = import ../../lib/ntfy.sh.nix { inherit pkgs; };

  # Create monitoring script that checks all configured filesystems
  monitorScript = pkgs.writeShellScript "disk-monitor" ''
    set -euo pipefail

    HOSTNAME=$(${pkgs.nettools}/bin/hostname)
    echo "Starting disk space monitoring on $HOSTNAME at $(date)"

    # Track if any errors occurred
    ERRORS=""
    WARNINGS=""

    ${lib.concatMapStringsSep "\n" (path: ''
      # Check ${path}
      echo "Checking ${path}..."

      # Get filesystem type
      FS_TYPE="${config.fileSystems.${path}.fsType or "unknown"}"
      THRESHOLD="${toString (cfg.monitoredPaths.${path} or cfg.defaultThreshold)}"

      # Get usage based on filesystem type
      if [[ "$FS_TYPE" == "btrfs" ]]; then
        # Use btrfs filesystem usage for accurate RAID-aware reporting
        if ! USAGE_OUTPUT=$(${pkgs.btrfs-progs}/bin/btrfs filesystem usage -b "${path}" 2>&1); then
          ERRORS="$ERRORS\nFailed to check ${path}: $USAGE_OUTPUT"
          continue
        fi

        # Extract used and total bytes
        USED=$(echo "$USAGE_OUTPUT" | ${pkgs.gnugrep}/bin/grep "Used:" | ${pkgs.gawk}/bin/awk '{print $2}')
        TOTAL=$(echo "$USAGE_OUTPUT" | ${pkgs.gnugrep}/bin/grep "Device size:" | ${pkgs.gawk}/bin/awk '{print $3}')

        if [[ -z "$USED" ]] || [[ -z "$TOTAL" ]] || [[ "$TOTAL" -eq 0 ]]; then
          ERRORS="$ERRORS\nFailed to parse btrfs usage for ${path}"
          continue
        fi

        PERCENTAGE=$((USED * 100 / TOTAL))
      else
        # Use df for other filesystems
        if ! DF_OUTPUT=$(${pkgs.coreutils}/bin/df -B1 "${path}" 2>&1); then
          ERRORS="$ERRORS\nFailed to check ${path}: $DF_OUTPUT"
          continue
        fi

        PERCENTAGE=$(echo "$DF_OUTPUT" | ${pkgs.gawk}/bin/awk 'NR==2 {gsub(/%/,"",$5); print $5}')
        USED=$(echo "$DF_OUTPUT" | ${pkgs.gawk}/bin/awk 'NR==2 {print $3}')
        TOTAL=$(echo "$DF_OUTPUT" | ${pkgs.gawk}/bin/awk 'NR==2 {print $2}')

        if [[ -z "$PERCENTAGE" ]]; then
          ERRORS="$ERRORS\nFailed to parse df output for ${path}"
          continue
        fi
      fi

      # Convert to human-readable
      USED_HUMAN=$(${pkgs.coreutils}/bin/numfmt --to=iec-i --suffix=B "$USED" 2>/dev/null || echo "$USED bytes")
      TOTAL_HUMAN=$(${pkgs.coreutils}/bin/numfmt --to=iec-i --suffix=B "$TOTAL" 2>/dev/null || echo "$TOTAL bytes")

      echo "${path}: $PERCENTAGE% used ($USED_HUMAN / $TOTAL_HUMAN)"

      # Check threshold
      if [[ "$PERCENTAGE" -ge "$THRESHOLD" ]]; then
        WARNINGS="$WARNINGS\n${path} is at $PERCENTAGE% ($USED_HUMAN / $TOTAL_HUMAN)"
      fi
    '') (lib.attrNames cfg.monitoredPaths)}

    # Send notifications if there were warnings
    if [[ -n "$WARNINGS" ]]; then
      ${ntfy.mkNotification {
        title = "Disk Space Warning";
        priority = "high";
        tags = "warning,disk,storage";
        message = "Disk space warning on $HOSTNAME:$WARNINGS";
        topicFile = cfg.ntfyTopicFile;
      }}
    fi

    # Send error notifications if there were errors
    if [[ -n "$ERRORS" ]]; then
      ${ntfy.mkNotification {
        title = "Disk Monitor Error";
        priority = "urgent";
        tags = "warning,disk,error";
        message = "Disk monitoring errors on $HOSTNAME:$ERRORS";
        topicFile = cfg.ntfyTopicFile;
      }}
      exit 1
    fi

    echo "Disk monitoring completed successfully on $HOSTNAME at $(date)"
  '';
in
{
  options.services.disk-monitor = {
    enable = lib.mkEnableOption "disk space monitoring with ntfy notifications";

    monitoredPaths = lib.mkOption {
      type = lib.types.attrsOf (lib.types.ints.between 1 100);
      default = { };
      description = ''
        Attribute set of filesystem paths to monitor with their threshold percentages.
        Paths must exist in config.fileSystems.
        Example: { "/" = 90; "/home" = 85; "/mnt/easystore" = 95; }
      '';
      example = {
        "/" = 90;
        "/home" = 85;
        "/mnt/data" = 95;
      };
    };

    defaultThreshold = lib.mkOption {
      type = lib.types.ints.between 1 100;
      default = 90;
      description = "Default threshold percentage for filesystems not explicitly configured";
    };

    ntfyTopicFile = lib.mkOption {
      type = lib.types.str;
      description = "Path to file containing the ntfy.sh topic";
      example = "/home/noah/ntfy_topic";
    };

    interval = lib.mkOption {
      type = lib.types.str;
      default = "hourly";
      description = "How often to run disk monitoring (systemd timer format)";
      example = "daily";
    };

    onCalendar = lib.mkOption {
      type = lib.types.nullOr lib.types.str;
      default = null;
      description = "Alternative to interval: specify exact schedule using systemd calendar format";
      example = "*-*-* 00,06,12,18:00:00";
    };

    randomizedDelaySec = lib.mkOption {
      type = lib.types.str;
      default = "5m";
      description = "Add random delay to avoid all checks running at exactly the same time";
    };
  };

  config = lib.mkIf cfg.enable {
    # Validate that all monitored paths exist in fileSystems
    assertions = [
      {
        assertion = cfg.monitoredPaths != { };
        message = "services.disk-monitor.monitoredPaths must not be empty when disk-monitor is enabled";
      }
      {
        assertion = cfg.ntfyTopicFile != "";
        message = "services.disk-monitor.ntfyTopicFile must be set";
      }
      {
        assertion = lib.all (path: config.fileSystems ? ${path}) (lib.attrNames cfg.monitoredPaths);
        message = "All paths in services.disk-monitor.monitoredPaths must exist in config.fileSystems. Invalid paths: ${
          lib.concatStringsSep ", " (
            lib.filter (path: !(config.fileSystems ? ${path})) (lib.attrNames cfg.monitoredPaths)
          )
        }";
      }
    ];

    systemd.services.disk-monitor = {
      description = "Monitor disk space and send notifications";
      serviceConfig = {
        Type = "oneshot";
        User = "root";
        ExecStart = "${monitorScript}";
      };
      path = with pkgs; [
        btrfs-progs
        coreutils
        gawk
        gnugrep
        nettools
        curl
      ];
    };

    systemd.timers.disk-monitor = {
      description = "Timer for disk space monitoring";
      wantedBy = [ "timers.target" ];
      timerConfig =
        {
          Persistent = true;
          RandomizedDelaySec = cfg.randomizedDelaySec;
        }
        // (
          if cfg.onCalendar != null then
            { OnCalendar = cfg.onCalendar; }
          else
            {
              OnCalendar = cfg.interval;
              OnBootSec = "10m";
            }
        );
    };
  };
}
