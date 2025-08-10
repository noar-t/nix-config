# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, ... }:

{
  imports = [
    # Include the results of the hardware scan.
    ./hardware-configuration.nix
    ../../nix.nix
    ./snapper.nix
  ];


  # Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  boot.kernelModules = [ "sg" ];
  boot.kernel.sysctl = {
    "kernel.task_delayacct" = 1;
  }; # flag for iotop

  system.autoUpgrade.enable = true;

  networking = {
    hostName = "rinsler";
    networkmanager.enable = true;
    firewall.enable = false;
    firewall.allowPing = true;
  };

  services.tailscale = {
    enable = true;
    useRoutingFeatures = "server";
    # TODO to authKey with secret manager
  };

  # Set your time zone.
  time.timeZone = "America/Los_Angeles";

  # Define accounts
  users.groups.noah.gid = 1000;
  users.users.noah = {
    isNormalUser = true;
    uid = 1000;
    home = "/home/noah";
    extraGroups = [
      "docker"
      "networkmanager"
      "noah"
      "wheel"
    ];
    shell = pkgs.fish;
    openssh.authorizedKeys.keys = [
      "ecdsa-sha2-nistp256 AAAAE2VjZHNhLXNoYTItbmlzdHAyNTYAAAAIbmlzdHAyNTYAAABBBG5/igfDm33qmKoujL1y8F/D2EInyUyJJE4fHZjZXKRYcDfrDp30QEd6CM7BFNJMREyzeZe4CBopIZld77YjKus= noah@WIN11-DESKTOP"
      "ecdsa-sha2-nistp256 AAAAE2VjZHNhLXNoYTItbmlzdHAyNTYAAAAIbmlzdHAyNTYAAABBBBY2D9VRvcblvSxfSWZKG59snFUoHbIuMrUohFhmjjtq0avSbiVUGRi1xIA3oUpsPkkn7qrNR5paCdYrECip3nQ= noah@nixos-laptop"
      "ecdsa-sha2-nistp256 AAAAE2VjZHNhLXNoYTItbmlzdHAyNTYAAAAIbmlzdHAyNTYAAABBBCD8aFvjd6RhUbJzvuhnyBiTmXX+PQ0uzs2ju85EnMUm+Wq7uCZ+AC8tO9IN0YiwEpIwhtNDJC/ZwzMSuEWIy9M= u0_a290@localhost"
      "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQDUjdiPWiGQ3o/xbdPWYtEK37tsSSu+rA8VLWneOkoEtIU1F8HyjwNKWBjn+Y/8syQUF3TghV8N2d2/HPGyltccgVfPVfdh+MKLwgVXAjnLA2IhMpLnghDSQFHNvSs/RIwi1ETHP5pdiPVLkzV2wv3sfSLiayAwXiyh0D5RKUUAlY/0LKrOOvsv/1slg6Q2pk8W4u2WCJhyVGqGmFv7X71U/aX7izvyyui/AJRS2XnIcCjgB439QRXy9yMyyFQfi9C0WV38u/grq0AUuDvVuXl1jzTTDw9M9Gk7yILnVTlsK0mtNwxR54Q2ay9EhB490sa//WFCVqoYiZHjvcwFc7qHAf+en1fr5mBRlaoAZRXaq3wKuhVynTS7w92GhKdQxjPhJxbML8yqVaYvsJ+USYIBowctaVqXoDBzM+PbAuvfQcs6Mff/BzGlzwOI5RPYIEjLKDva/mBVQWm77PdqHW4r59TPE7eY6T0KqGTvto0X+N0NiQwsLHB0p+9hpEJ/3XU= u0_a178@localhost"
    ];
  };

  environment.sessionVariables = {
    # Docker compose variables
    UID = "1000";
    GID = "1000";
    DOCKERDIR = "/home/docker/";
    TV = "/mnt/easystore/tvShows";
    MOVIES = "/mnt/easystore/movies";
    NZBDIR = "/mnt/easystore/nzb";
    DOWNLOADS = "/mnt/easystore/downloads";
    TZ = "America/Los_Angeles";
  };

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    borgbackup
    cargo
    docker
    docker-compose
    eza
    ffmpeg
    mosh
    nodejs_20
    tailscale
    wget
    gemini-cli
  ];

  programs.fish.enable = true;
  programs.neovim.enable = true;
  programs.neovim.defaultEditor = true;

  services.pulseaudio.enable = false;

  # required for AlderLake igpu
  boot.kernelParams = [ "i915.force_probe=4692" ];

  # Hardware accelerration for ffmpeg
  nixpkgs.config.packageOverrides = pkgs: {
    vaapiIntel = pkgs.vaapiIntel.override { enableHybridCodec = true; };
  };

  hardware.graphics = {
    enable = true;
    extraPackages = with pkgs; [
      intel-media-driver # LIBVA_DRIVER_NAME=iHD
      vaapiIntel # LIBVA_DRIVER_NAME=i965 (older but works better for Firefox/Chromium)
      vaapiVdpau
      libvdpau-va-gl
    ];
  };

  # Enable the OpenSSH daemon.
  services.openssh = {
    enable = true;
    banner = "Welcome to my nixos server!\n";
    settings.X11Forwarding = true;
    settings.KbdInteractiveAuthentication = false;
    ports = [ 1111 ];
  };

  virtualisation.docker.enable = true;

  services.nfs.server = {
    enable = true;
    exports = ''
      /mnt/easystore 192.168.0.0/24(insecure,rw,sync,no_subtree_check)
    '';
  };

  services = {
    samba = {
      enable = true;
      settings = {
        global = {
          security = "user";
          "guest account" = "noah";
          "map to guest" = "Bad User";

          "load printers" = "no";
          "printcap name" = "/dev/null";

          "log file" = "/var/log/samba/client.%I";
          "log level" = 2;
        };
        # Share named samba
        samba = {
          path = "/mnt/easystore";
          browsable = "yes";
          "read only" = "yes";
          "guest ok" = "yes";
          "create mask" = "0644";
          "directory mask" = "0755";
        };
      };

    };

    samba-wsdd = {
      enable = true;
    };
  };

  system.stateVersion = "24.05";
}
