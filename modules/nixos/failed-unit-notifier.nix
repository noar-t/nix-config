{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.services.failed-unit-notifier;
  ntfy = import ../../lib/ntfy.sh.nix { inherit pkgs; };

  # Get all systemd service names defined in this NixOS config
  configuredServices = lib.attrNames config.systemd.services;

  # Build the list of units to check (as .service unit names)
  unitsToMonitor = map (name: "${name}.service") configuredServices;

  notifierScript = pkgs.writeShellScript "failed-unit-notifier" ''
    set -euo pipefail

    HOSTNAME=$(${pkgs.nettools}/bin/hostname)
    STATE_FILE="/var/lib/failed-unit-notifier/notified-failures"

    # Ensure state directory exists
    mkdir -p "$(dirname "$STATE_FILE")"
    touch "$STATE_FILE"

    echo "Checking for failed systemd units on $HOSTNAME at $(date)"

    # Units defined in NixOS config to monitor
    UNITS_TO_CHECK=(${lib.concatMapStringsSep " " (u: "\"${u}\"") unitsToMonitor})

    echo "Monitoring ${toString (lib.length unitsToMonitor)} units from NixOS config"

    # Check each configured unit for failure
    FAILED_UNITS=""
    for unit in "''${UNITS_TO_CHECK[@]}"; do
      if ${pkgs.systemd}/bin/systemctl is-failed --quiet "$unit" 2>/dev/null; then
        if [[ -z "$FAILED_UNITS" ]]; then
          FAILED_UNITS="$unit"
        else
          FAILED_UNITS="$FAILED_UNITS"$'\n'"$unit"
        fi
      fi
    done

    if [[ -z "$FAILED_UNITS" ]]; then
      echo "No failed units found"
      # Clear the state file since there are no failures
      > "$STATE_FILE"
      exit 0
    fi

    FAILED_UNITS=$(echo "$FAILED_UNITS" | sort)
    echo "Failed units: $FAILED_UNITS"

    # Read previously notified failures
    PREV_NOTIFIED=$(cat "$STATE_FILE" | sort)

    # Find new failures (units that are failed but weren't previously notified)
    NEW_FAILURES=$(comm -23 <(echo "$FAILED_UNITS") <(echo "$PREV_NOTIFIED"))

    if [[ -n "$NEW_FAILURES" ]]; then
      echo "New failures detected: $NEW_FAILURES"

      # Format the message
      FAILURE_LIST=$(echo "$NEW_FAILURES" | ${pkgs.coreutils}/bin/tr '\n' ', ' | ${pkgs.gnused}/bin/sed 's/,$//')

      ${ntfy.mkNotification {
        title = "Systemd Unit Failed";
        priority = "high";
        tags = "warning,systemd,failure";
        message = "Failed units on $HOSTNAME: $FAILURE_LIST";
        topicFile = cfg.ntfyTopicFile;
      }}

      echo "Notification sent for: $FAILURE_LIST"
    else
      echo "No new failures to report"
    fi

    # Update state file with current failed units
    echo "$FAILED_UNITS" > "$STATE_FILE"

    echo "Check completed at $(date)"
  '';
in
{
  options.services.failed-unit-notifier = {
    enable = lib.mkEnableOption "failed systemd unit notifications via ntfy";

    ntfyTopicFile = lib.mkOption {
      type = lib.types.str;
      description = "Path to file containing the ntfy.sh topic";
      example = "/home/noah/ntfy_topic";
    };

    interval = lib.mkOption {
      type = lib.types.str;
      default = "*:0/15";
      description = "How often to check for failed units (systemd OnCalendar format). Default: every 15 minutes.";
      example = "hourly";
    };

    randomizedDelaySec = lib.mkOption {
      type = lib.types.str;
      default = "1m";
      description = "Add random delay to avoid exact timing";
    };
  };

  config = lib.mkIf cfg.enable {
    assertions = [
      {
        assertion = cfg.ntfyTopicFile != "";
        message = "services.failed-unit-notifier.ntfyTopicFile must be set";
      }
    ];

    systemd.services.failed-unit-notifier = {
      description = "Monitor for failed systemd units and send notifications";
      serviceConfig = {
        Type = "oneshot";
        ExecStart = "${notifierScript}";
        StateDirectory = "failed-unit-notifier";
      };
      path = with pkgs; [
        coreutils
        gawk
        gnused
        nettools
        systemd
        curl
      ];
    };

    systemd.timers.failed-unit-notifier = {
      description = "Timer for failed systemd unit monitoring";
      wantedBy = [ "timers.target" ];
      timerConfig = {
        OnCalendar = cfg.interval;
        OnBootSec = "5m";
        Persistent = true;
        RandomizedDelaySec = cfg.randomizedDelaySec;
      };
    };
  };
}
