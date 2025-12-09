{ config, pkgs, ... }:

{
  systemd.services.nix-flake-auto-update = {
    description = "Automatically update nix flake and apply changes";
    serviceConfig = {
      Type = "oneshot";
      User = "noah";
      Group = "noah";
      WorkingDirectory = "/home/noah/nix-config";
      Environment = [
        "PATH=${pkgs.lib.makeBinPath [ pkgs.git pkgs.nix pkgs.curl pkgs.nettools pkgs.coreutils pkgs.openssh ]}"
      ];
    };
    script = ''
      set -euo pipefail

      echo "Starting flake auto-update at $(date)"

      # Check if we're in a clean git state
      if ! git diff-index --quiet HEAD --; then
        echo "Working directory not clean, aborting update"
        exit 1
      fi

      # Sync with remote repository
      echo "Syncing with remote repository..."
      git fetch origin
      if ! git diff-index --quiet HEAD -- origin/master; then
        echo "Local branch is behind remote, pulling changes..."
        git pull --rebase origin master
      fi

      # Update the flake
      echo "Updating flake inputs..."
      nix flake update

      # Check if there are any changes after update
      if git diff-index --quiet HEAD --; then
        echo "No updates available"
        exit 0
      fi

      # Check that the flake builds correctly
      echo "Checking flake configuration..."
      if ! nix flake check; then
        echo "Flake check failed, reverting changes"
        git checkout -- .
        exit 1
      fi

      # Commit the changes
      echo "Committing changes..."
      git add flake.lock
      git commit -m "chore: update flake"

      # Push the changes
      echo "Pushing changes..."
      if ! git push origin master; then
        echo "Push failed, but system is updated. Manual intervention required."
        exit 1
      fi

      echo "Flake auto-update completed successfully at $(date)"
    '';

    requisite = [ "systemd-logind.service" ];

    # Don't restart on failure
    restartIfChanged = false;

    onFailure = [ "nix-flake-auto-update-notify-failure.service" ];
  };

  systemd.timers.nix-flake-auto-update = {
    description = "Timer for automatic nix flake updates";
    wantedBy = [ "timers.target" ];
    timerConfig = {
      # Run bi-monthly on the 1st and 15th at 2 AM
      OnCalendar = "*-*-01,15 02:00:00";
      # Add some randomization to avoid conflicts
      RandomizedDelaySec = "30m";
      # Ensure we don't run too frequently
      Persistent = true;
      # Only run if system has been up for at least 10 minutes
      OnBootSec = "10m";
    };
  };

  systemd.services.nix-flake-auto-update-notify-failure = {
    description = "Send notification when nix flake auto-update fails";
    serviceConfig = {
      Type = "oneshot";
      User = "noah";
      Group = "noah";
      WorkingDirectory = "/home/noah/nix-config";
      Environment = [
        "PATH=${pkgs.lib.makeBinPath [ pkgs.curl pkgs.nettools pkgs.coreutils ]}"
      ];
    };
    script = ''
      ${pkgs.curl}/bin/curl \
        -H "Title: Auto-Update Failed" \
        -H "Priority: urgent" \
        -H "Tags: warning,auto-update" \
        -d "Nix flake auto-update failed on $(${pkgs.nettools}/bin/hostname)" \
        ntfy.sh/$(cat /home/noah/ntfy_topic)
    '';
  };
}