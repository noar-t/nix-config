{ config, lib, pkgs, ... }:

{
  # Simply install just the packages
  environment.packages = with pkgs; [
    # Some common stuff that people expect to have
    diffutils
    findutils
    utillinux
    tzdata
    hostname
    gnupg
    gnused
    gnutar
    bzip2
    gzip
    xz

    # User added

    elmPackages.elm
    eza
    fish
    git
    gnugrep
    htop
    man
    #neovim
    openssh
    ps
    python3
    tmux
    tree
    unzip
    vim
    which
    zip
  ];

  #user.shell = pkgs.fish;

  # Backup etc files instead of failing to activate generation if a file already exists in /etc (nix-on-droid)
  environment.etcBackupExtension = ".bak";

  # Read the changelog before changing this value
  system.stateVersion = "23.11";

  # Set up nix for flakes
  nix.extraOptions = ''
    experimental-features = nix-command flakes
  '';

  # Set your time zone
  time.timeZone = "America/Los_Angeles";
}
