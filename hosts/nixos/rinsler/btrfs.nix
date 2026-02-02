{
  ...
}:
{
  # Disable the built-in scrub in favor of our custom day/night scheduling
  services.btrfs.autoScrub.enable = false;

  services.btrfs-scrub = {
    enable = true;
    fileSystems = [
      "/"
      "/home"
      "/mnt/easystore"
    ];
    resumeTime = "*-*-* 01:00:00"; # 1 AM - resume scrubbing
    pauseTime = "*-*-* 08:00:00"; # 8 AM - pause scrubbing
    startInterval = "monthly";
    ntfyTopicFile = "/home/noah/ntfy_topic";
  };
}
