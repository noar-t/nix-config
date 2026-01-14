{ ... }:

{
  services.disk-monitor = {
    enable = true;

    # Monitor critical filesystems with thresholds
    # Filesystem types are automatically detected from config.fileSystems
    monitoredPaths = {
      "/" = 90;
      "/home" = 90;
      "/mnt/easystore" = 90; # BTRFS RAID5 - will use btrfs tools automatically
    };

    # Use the same ntfy topic as auto-update
    ntfyTopicFile = "/home/noah/ntfy_topic";

    # Check every 6 hours
    onCalendar = "*-*-* 00,06,12,18:00:00";

    # Add a small random delay to avoid exact timing conflicts
    randomizedDelaySec = "5m";
  };
}
