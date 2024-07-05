{ config, pkgs, ... }:

{
  networking.hostName = "wsl";

  # Set your time zone.
  time.timeZone = "America/Los_Angeles";

  # Define accounts
  users.users.noah = {
    isNormalUser = true;
    uid = 1000;
    home = "/home/noah";
    shell = pkgs.fish;
    packages = with pkgs; [
    ];
  };

  users.groups.noah.gid = 1000;

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    borgbackup
    cargo
    eza
    ffmpeg
    fish
    fzf
    git
    gcc
    htop
    iotop-c
    neovim
    nodejs_20
    stress
    tmux
    tree
    wget
  ];

  programs.fish.enable = true;
  programs.neovim.enable = true;
  programs.neovim.defaultEditor = true;


  nix = {
    package = pkgs.nixFlakes;
    extraOptions = ''
      experimental-features = nix-command flakes
    '';
  };

  system.stateVersion = "24.05";
  wsl = {
    enable = true;
    defaultUser = "noah";
  };
}

