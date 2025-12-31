{ pkgs, ... }:

let
  ntfy = import ../../../lib/ntfy.sh.nix { inherit pkgs; };
in
{
  environment.systemPackages = [ pkgs.borgbackup ];

  services.borgbackup.jobs = {
    home-backup = {
      startAt = "daily";

      paths = [
        "/home/noah"
        "/home/docker"
        "/var/lib/docker/"
      ];

      encryption.passCommand = "cat /home/noah/borg_pass";
      encryption.mode = "repokey";

      environment.BORG_RSH = "ssh -i /home/noah/.ssh/id_ed25519";
      environment.BORG_RELOCATED_REPO_ACCESS_IS_OK = "yes";

      repo = "ssh://noah@wyzevault:22/mnt/storage/borgbackup";
      extraCreateArgs = "--verbose --stats";
      compression = "auto,zstd";

      postHook = ''
        if [ "$exitStatus" -gt "1" ]; then
          ${ntfy.mkNotification {
            title = "Backup Failed";
            priority = "urgent";
            tags = "warning,backup";
            message = "Remote Borg backup (home-backup) failed with exit code $exitStatus on $(${pkgs.inetutils}/bin/hostname)";
            topicFile = "/home/noah/ntfy_topic";
          }}
        fi
      '';

      prune.keep = {
        daily = 7;
        weekly = 4;
        monthly = 6;
      };
    };

    home-backup-local = {
      startAt = "02:00";

      paths = [
        "/home/noah"
        "/home/docker"
        "/var/lib/docker/"
      ];

      encryption.passCommand = "cat /home/noah/borg_pass";
      encryption.mode = "repokey";

      environment.BORG_RELOCATED_REPO_ACCESS_IS_OK = "yes";

      repo = "/mnt/easystore/backups/borg";
      extraCreateArgs = "--verbose --stats";
      compression = "auto,zstd";

      postHook = ''
        if [ "$exitStatus" -gt "1" ]; then
          ${ntfy.mkNotification {
            title = "Backup Failed";
            priority = "urgent";
            tags = "warning,backup";
            message = "Local Borg backup (home-backup-local) failed with exit code $exitStatus on $(${pkgs.inetutils}/bin/hostname)";
            topicFile = "/home/noah/ntfy_topic";
          }}
        fi
      '';

      prune.keep = {
        daily = 7;
        weekly = 4;
        monthly = 6;
      };
    };
  };
}
