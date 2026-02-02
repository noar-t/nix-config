{
  config,
  pkgs,
  lib,
  ...
}:

let
  cfg = config.services.btrfs-scrub;
  ntfy = import ../../lib/ntfy.sh.nix { inherit pkgs; };

  # Escape a filesystem path for use in systemd unit names
  escapePath =
    path:
    let
      stripped = lib.removePrefix "/" path;
    in
    if stripped == "" then "root" else builtins.replaceStrings [ "/" ] [ "-" ] stripped;

  mkScrubUnits =
    fs:
    let
      name = escapePath fs;
      btrfs = "${pkgs.btrfs-progs}/bin/btrfs";
    in
    {
      # Service that starts a fresh scrub (monthly trigger)
      services."btrfs-scrub-start-${name}" = {
        description = "BTRFS scrub start for ${fs}";
        serviceConfig = {
          Type = "oneshot";
          IOSchedulingClass = cfg.ioSchedulingClass;
          CPUSchedulingPolicy = cfg.cpuSchedulingPolicy;
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
            # Exit code 3 means the scrub was cancelled (paused) - that's expected
            if [ $exit_code -eq 3 ]; then
              echo "Scrub on ${fs} was paused, will resume later"
              exit 0
            fi
            exit $exit_code
          }
        '';
        onFailure = lib.mkIf (cfg.ntfyTopicFile != null) [
          "btrfs-scrub-notify-failure-${name}.service"
        ];
      };

      # Timer for starting fresh scrubs
      timers."btrfs-scrub-start-${name}" = {
        description = "Timer for BTRFS scrub start on ${fs}";
        wantedBy = [ "timers.target" ];
        timerConfig = {
          OnCalendar = cfg.startInterval;
          Persistent = true;
        };
      };

      # Service that resumes a paused scrub (nightly)
      services."btrfs-scrub-resume-${name}" = {
        description = "BTRFS scrub resume for ${fs}";
        serviceConfig = {
          Type = "oneshot";
          IOSchedulingClass = cfg.ioSchedulingClass;
          CPUSchedulingPolicy = cfg.cpuSchedulingPolicy;
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
              # Exit code 3 means cancelled again (paused) - expected
              if [ $exit_code -eq 3 ]; then
                echo "Scrub on ${fs} was paused, will resume later"
                exit 0
              fi
              # Exit code 2 means nothing to resume
              if [ $exit_code -eq 2 ]; then
                echo "Nothing to resume on ${fs}"
                exit 0
              fi
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

      # Timer for nightly resume
      timers."btrfs-scrub-resume-${name}" = {
        description = "Timer for BTRFS scrub resume on ${fs}";
        wantedBy = [ "timers.target" ];
        timerConfig = {
          OnCalendar = cfg.resumeTime;
          Persistent = false;
        };
      };

      # Service that pauses a running scrub (morning)
      services."btrfs-scrub-pause-${name}" = {
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

      # Timer for morning pause
      timers."btrfs-scrub-pause-${name}" = {
        description = "Timer for BTRFS scrub pause on ${fs}";
        wantedBy = [ "timers.target" ];
        timerConfig = {
          OnCalendar = cfg.pauseTime;
          Persistent = false;
        };
      };
    }
    // lib.optionalAttrs (cfg.ntfyTopicFile != null) {
      # Failure notification service
      services."btrfs-scrub-notify-failure-${name}" = {
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

  # Merge all per-filesystem units
  allUnits = lib.foldl' (
    acc: fs:
    let
      units = mkScrubUnits fs;
    in
    {
      services = acc.services // (units.services or { });
      timers = acc.timers // (units.timers or { });
    }
  ) { services = { }; timers = { }; } cfg.fileSystems;
in
{
  options.services.btrfs-scrub = {
    enable = lib.mkEnableOption "BTRFS scrub with day/night scheduling";

    fileSystems = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [ "/" ];
      description = "List of BTRFS filesystem paths to scrub";
    };

    resumeTime = lib.mkOption {
      type = lib.types.str;
      default = "*-*-* 22:00:00";
      description = "Systemd OnCalendar expression for when to resume scrubs (evening)";
    };

    pauseTime = lib.mkOption {
      type = lib.types.str;
      default = "*-*-* 08:00:00";
      description = "Systemd OnCalendar expression for when to pause scrubs (morning)";
    };

    startInterval = lib.mkOption {
      type = lib.types.str;
      default = "monthly";
      description = "Systemd OnCalendar expression for when to start fresh scrubs";
    };

    ioSchedulingClass = lib.mkOption {
      type = lib.types.str;
      default = "idle";
      description = "I/O scheduling class for scrub processes";
    };

    cpuSchedulingPolicy = lib.mkOption {
      type = lib.types.str;
      default = "idle";
      description = "CPU scheduling policy for scrub processes";
    };

    ntfyTopicFile = lib.mkOption {
      type = lib.types.nullOr lib.types.str;
      default = null;
      description = "Path to file containing ntfy topic for failure notifications";
    };
  };

  config = lib.mkIf cfg.enable {
    systemd.services = allUnits.services;
    systemd.timers = allUnits.timers;
  };
}
