{
  config,
  pkgs,
  lib,
  ...
}:

let
  cfg = config.services.btrfs-scrub;
  ntfy = import ../../lib/ntfy.sh.nix { inherit pkgs; };

  intervalToCalendar = {
    monthly = "*-*-01 02:00:00";
    quarterly = "*-01,04,07,10-01 02:00:00";
  };

  # Escape a filesystem path for use in systemd unit names
  escapePath =
    path:
    let
      stripped = lib.removePrefix "/" path;
    in
    if stripped == "" then "root" else builtins.replaceStrings [ "/" ] [ "-" ] stripped;

  fsSubmodule = lib.types.submodule {
    options = {
      mount = lib.mkOption {
        type = lib.types.str;
        description = "BTRFS filesystem mount path to scrub";
      };

      resumeTime = lib.mkOption {
        type = lib.types.str;
        default = cfg.defaults.resumeTime;
        defaultText = lib.literalExpression "config.services.btrfs-scrub.defaults.resumeTime";
        description = "Systemd OnCalendar expression for when to resume scrubs";
      };

      pauseTime = lib.mkOption {
        type = lib.types.str;
        default = cfg.defaults.pauseTime;
        defaultText = lib.literalExpression "config.services.btrfs-scrub.defaults.pauseTime";
        description = "Systemd OnCalendar expression for when to pause scrubs";
      };

      startInterval = lib.mkOption {
        type = lib.types.enum [ "monthly" "quarterly" ];
        default = cfg.defaults.startInterval;
        defaultText = lib.literalExpression "config.services.btrfs-scrub.defaults.startInterval";
        description = "How often to start fresh scrubs";
      };

      ioSchedulingClass = lib.mkOption {
        type = lib.types.str;
        default = cfg.defaults.ioSchedulingClass;
        defaultText = lib.literalExpression "config.services.btrfs-scrub.defaults.ioSchedulingClass";
        description = "I/O scheduling class for scrub processes";
      };

      cpuSchedulingPolicy = lib.mkOption {
        type = lib.types.str;
        default = cfg.defaults.cpuSchedulingPolicy;
        defaultText = lib.literalExpression "config.services.btrfs-scrub.defaults.cpuSchedulingPolicy";
        description = "CPU scheduling policy for scrub processes";
      };
    };
  };

  mkScrubUnits =
    fsCfg:
    let
      fs = fsCfg.mount;
      name = escapePath fs;
      btrfs = "${pkgs.btrfs-progs}/bin/btrfs";
    in
    {
      services = {
        "btrfs-scrub-start-${name}" = {
          description = "BTRFS scrub start for ${fs}";
          serviceConfig = {
            Type = "oneshot";
            IOSchedulingClass = fsCfg.ioSchedulingClass;
            CPUSchedulingPolicy = fsCfg.cpuSchedulingPolicy;
            Nice = 19;
          };
          script = ''
            # Check if a scrub is already running
            if ${btrfs} scrub status ${fs} | grep -q "running"; then
              echo "Scrub already running on ${fs}, skipping start"
              exit 0
            fi
            echo "Starting scrub on ${fs}"
            ${btrfs} scrub start -B ${fs} || {
              exit_code=$?
              # Check if scrub was paused/cancelled (exit codes 1 or 3)
              new_status=$(${btrfs} scrub status ${fs})
              if echo "$new_status" | grep -q "aborted\|interrupted\|cancelled"; then
                echo "Scrub on ${fs} was paused, will resume later"
                exit 0
              fi
              echo "Scrub failed with exit code $exit_code"
              exit $exit_code
            }
          '';
          onFailure = lib.mkIf (cfg.ntfyTopicFile != null) [
            "btrfs-scrub-notify-failure-${name}.service"
          ];
        };

        "btrfs-scrub-resume-${name}" = {
          description = "BTRFS scrub resume for ${fs}";
          serviceConfig = {
            Type = "oneshot";
            IOSchedulingClass = fsCfg.ioSchedulingClass;
            CPUSchedulingPolicy = fsCfg.cpuSchedulingPolicy;
            Nice = 19;
          };
          script = ''
            # Check if there's a scrub to resume
            status=$(${btrfs} scrub status ${fs})
            if echo "$status" | grep -q "no stats available"; then
              echo "No scrub to resume on ${fs}"
              exit 0
            fi
            if echo "$status" | grep -q "running"; then
              echo "Scrub already running on ${fs}"
              exit 0
            fi
            # Only resume if there's an interrupted/cancelled scrub
            if echo "$status" | grep -q "aborted\|interrupted\|cancelled"; then
              echo "Resuming scrub on ${fs}"
              ${btrfs} scrub resume -B ${fs} || {
                exit_code=$?
                # Exit code 2 means nothing to resume
                if [ $exit_code -eq 2 ]; then
                  echo "Nothing to resume on ${fs}"
                  exit 0
                fi
                # Check if scrub was paused/cancelled (exit codes 1 or 3)
                # btrfs scrub resume returns 1 when cancelled externally, not 3
                new_status=$(${btrfs} scrub status ${fs})
                if echo "$new_status" | grep -q "aborted\|interrupted\|cancelled"; then
                  echo "Scrub on ${fs} was paused, will resume later"
                  exit 0
                fi
                echo "Scrub failed with exit code $exit_code"
                exit $exit_code
              }
            else
              echo "No interrupted scrub to resume on ${fs}, status: $status"
              exit 0
            fi
          '';
          onFailure = lib.mkIf (cfg.ntfyTopicFile != null) [
            "btrfs-scrub-notify-failure-${name}.service"
          ];
        };

        "btrfs-scrub-pause-${name}" = {
          description = "BTRFS scrub pause for ${fs}";
          serviceConfig = {
            Type = "oneshot";
          };
          script = ''
            if ${btrfs} scrub status ${fs} | grep -q "running"; then
              echo "Pausing scrub on ${fs}"
              ${btrfs} scrub cancel ${fs}
            else
              echo "No scrub running on ${fs}, nothing to pause"
            fi
          '';
        };
      }
      // lib.optionalAttrs (cfg.ntfyTopicFile != null) {
        "btrfs-scrub-notify-failure-${name}" = {
          description = "Send notification when BTRFS scrub fails on ${fs}";
          serviceConfig = {
            Type = "oneshot";
            Environment = [
              "PATH=${
                pkgs.lib.makeBinPath [
                  pkgs.curl
                  pkgs.nettools
                  pkgs.coreutils
                ]
              }"
            ];
          };
          script = ntfy.mkNotification {
            title = "BTRFS Scrub Failed";
            priority = "high";
            tags = "warning,btrfs,scrub";
            message = "BTRFS scrub failed on ${fs} on $(${pkgs.nettools}/bin/hostname)";
            topicFile = cfg.ntfyTopicFile;
          };
        };
      };

      timers = {
        "btrfs-scrub-start-${name}" = {
          description = "Timer for BTRFS scrub start on ${fs}";
          wantedBy = [ "timers.target" ];
          timerConfig = {
            OnCalendar = intervalToCalendar.${fsCfg.startInterval};
            Persistent = true;
          };
        };

        "btrfs-scrub-resume-${name}" = {
          description = "Timer for BTRFS scrub resume on ${fs}";
          wantedBy = [ "timers.target" ];
          timerConfig = {
            OnCalendar = fsCfg.resumeTime;
            Persistent = false;
          };
        };

        "btrfs-scrub-pause-${name}" = {
          description = "Timer for BTRFS scrub pause on ${fs}";
          wantedBy = [ "timers.target" ];
          timerConfig = {
            OnCalendar = fsCfg.pauseTime;
            Persistent = false;
          };
        };
      };
    };

  # Merge all per-filesystem units
  mergeUnits =
    acc: fsCfg:
    let
      units = mkScrubUnits fsCfg;
    in
    {
      services = acc.services // (units.services or { });
      timers = acc.timers // (units.timers or { });
    };

  allUnits = lib.foldl' mergeUnits {
    services = { };
    timers = { };
  } cfg.fileSystems;
in
{
  options.services.btrfs-scrub = {
    enable = lib.mkEnableOption "BTRFS scrub with day/night scheduling";

    fileSystems = lib.mkOption {
      type = lib.types.listOf fsSubmodule;
      default = [ ];
      description = "List of BTRFS filesystems to scrub, each with its own schedule options";
    };

    ntfyTopicFile = lib.mkOption {
      type = lib.types.nullOr lib.types.str;
      default = null;
      description = "Path to file containing ntfy topic for failure notifications";
    };

    defaults = {
      resumeTime = lib.mkOption {
        type = lib.types.str;
        default = "*-*-* 02:00:00";
        description = "Default systemd OnCalendar expression for when to resume scrubs";
      };

      pauseTime = lib.mkOption {
        type = lib.types.str;
        default = "*-*-* 08:00:00";
        description = "Default systemd OnCalendar expression for when to pause scrubs";
      };

      startInterval = lib.mkOption {
        type = lib.types.enum [ "monthly" "quarterly" ];
        default = "monthly";
        description = "Default scrub frequency";
      };

      ioSchedulingClass = lib.mkOption {
        type = lib.types.str;
        default = "idle";
        description = "Default I/O scheduling class for scrub processes";
      };

      cpuSchedulingPolicy = lib.mkOption {
        type = lib.types.str;
        default = "idle";
        description = "Default CPU scheduling policy for scrub processes";
      };
    };
  };

  config = lib.mkIf cfg.enable {
    assertions = [
      {
        assertion = !config.services.btrfs.autoScrub.enable;
        message = "services.btrfs.autoScrub.enable must be false when using services.btrfs-scrub, as they would conflict.";
      }
    ];

    systemd.services = allUnits.services;
    systemd.timers = allUnits.timers;
  };
}
