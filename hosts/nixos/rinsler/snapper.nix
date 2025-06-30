{ config, pkgs, ... }:

{
  environment.systemPackages = [ pkgs.snapper ];
  services.snapper.configs = {
    home = {
      SUBVOLUME = "/home";
      FSTYPE = "btrfs";
      ALLOW_USERS = [ "noah" ];
      TIMELINE_CREATE = true;
      TIMELINE_CLEANUP = true;
      TIMELINE_LIMIT_YEARLY = 1;
      TIMELINE_LIMIT_QUARTERLY = 2;
      TIMELINE_LIMIT_MONTHLY = 3;
      TIMELINE_LIMIT_WEEKLY = 2;
      TIMELINE_LIMIT_DAILY = 4;
    };
  };
}
