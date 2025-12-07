{ config, pkgs, ... }:

{
  environment.systemPackages = [ pkgs.borgbackup ];

  services.borgbackup.jobs.home-backup = {
    startAt = "daily";

    paths = [ "/home/noah" "/home/docker" "/var/lib/docker/" ];

    encryption.passCommand = "cat /home/noah/borg_pass";
    encryption.mode = "repokey";

    environment.BORG_RSH = "ssh -i /home/noah/.ssh/id_ed25519";
    environment.BORG_RELOCATED_REPO_ACCESS_IS_OK = "yes";

    repo = "ssh://noah@wyzevault:22/mnt/storage/borgbackup";
    extraCreateArgs = "--verbose --stats";
    compression = "auto,zstd";

    prune.keep = {
      daily = 7;
      weekly = 4;
      monthly = 6;
    };
  };
}