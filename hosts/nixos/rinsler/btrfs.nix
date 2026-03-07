{
  ...
}:
{
  services.btrfs-scrub = {
    enable = true;
    ntfyTopicFile = "/home/noah/ntfy_topic";

    fileSystems = [
      { mount = "/"; }
      { mount = "/home"; }
      {
        mount = "/mnt/easystore";
        # This scrub takes ~20 days, so monthly is overkill
        startInterval = "quarterly";
      }
    ];
  };
}
