{
  config,
  pkgs,
  lib,
  ...
}:

let
  cfg = config.services.nix-flake-auto-apply-update;
  ntfy = import ../../lib/ntfy.sh.nix { inherit pkgs; };
in
{
  options.services.nix-flake-auto-apply-update = {
    enable = lib.mkEnableOption "automatic flake update application from git updates";

    workingDirectory = lib.mkOption {
      type = lib.types.str;
      default = "/home/noah/nix-config";
      description = "Directory containing the nix flake";
    };

    schedule = lib.mkOption {
      type = lib.types.str;
      default = "*-*-* 03:00:00";
      description = "Systemd calendar schedule for auto-apply";
    };

    randomizedDelay = lib.mkOption {
      type = lib.types.str;
      default = "15m";
      description = "Maximum randomized delay for the timer";
    };

    user = lib.mkOption {
      type = lib.types.str;
      default = "noah";
      description = "User for notifications";
    };

    ntfyTopicFile = lib.mkOption {
      type = lib.types.str;
      default = "/home/noah/ntfy_topic";
      description = "Path to file containing ntfy topic";
    };
  };

  config = lib.mkIf cfg.enable {
    systemd.services.nix-flake-auto-apply-update = {
      description = "Automatically pull flake updates and rebuild system";
      serviceConfig = {
        Type = "oneshot";
        User = "root";
        WorkingDirectory = cfg.workingDirectory;
        Environment = [
          "PATH=${
            pkgs.lib.makeBinPath [
              pkgs.git
              pkgs.nix
              pkgs.curl
              pkgs.nettools
              pkgs.coreutils
              pkgs.openssh
            ]
          }"
        ];
      };
      script = ''
        set -euo pipefail

        echo "Starting flake auto-apply at $(date)"

        # Check if we're in a clean git state (as noah)
        if ! sudo -u noah git diff-index --quiet HEAD --; then
          echo "Working directory not clean, skipping apply"
          exit 0
        fi

        # Fetch from remote repository (as noah)
        echo "Fetching from remote repository..."
        sudo -u noah git fetch origin

        # Check if there are updates (as noah)
        if sudo -u noah git diff-index --quiet HEAD -- origin/master; then
          echo "No updates available"
          exit 0
        fi

        echo "Updates found, pulling changes..."
        sudo -u noah git pull --rebase origin master

        # Check that the flake builds correctly (as root)
        echo "Checking flake configuration..."
        if ! nix flake check; then
          echo "Flake check failed, reverting changes"
          sudo -u noah git checkout HEAD~1
          exit 1
        fi

        # Build the new configuration (as root)
        echo "Building new configuration..."
        if ! nixos-rebuild build --flake .; then
          echo "Build failed, reverting changes"
          sudo -u noah git checkout HEAD~1
          exit 1
        fi

        # Apply the new configuration (as root)
        echo "Applying new configuration..."
        if ! nixos-rebuild switch --flake .; then
          echo "Switch failed, but build succeeded. Manual intervention may be needed."
          exit 1
        fi

        echo "Flake auto-apply completed successfully at $(date)"
      '';

      requisite = [ "network-online.target" ];
      restartIfChanged = false;
      onFailure = [ "nix-flake-auto-apply-update-notify-failure.service" ];
    };

    systemd.timers.nix-flake-auto-apply-update = {
      description = "Timer for automatic nix flake update application";
      wantedBy = [ "timers.target" ];
      timerConfig = {
        OnCalendar = cfg.schedule;
        RandomizedDelaySec = cfg.randomizedDelay;
        Persistent = true;
        OnBootSec = "15m";
      };
    };

    systemd.services.nix-flake-auto-apply-update-notify-failure = {
      description = "Send notification when nix flake auto-apply-update fails";
      serviceConfig = {
        Type = "oneshot";
        User = cfg.user;
        Group = cfg.user;
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
        title = "Auto-Apply-Update Failed";
        priority = "high";
        tags = "warning,auto-apply-update";
        message = "Nix flake auto-apply-update failed on $(${pkgs.nettools}/bin/hostname)";
        topicFile = cfg.ntfyTopicFile;
      };
    };
  };
}
