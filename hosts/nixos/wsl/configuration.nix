{ pkgs, inputs, ... }:

{
  imports = [
    ../../nix.nix
    inputs.nixos-wsl.nixosModules.default
  ];

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
    elixir
    ffmpeg
    fish
    fzf
    git
    gcc
    htop
    iotop-c
    lua
    neovim
    nodejs_20
    python3
    stress
    tmux
    tree
    wget
  ];

  programs.fish.enable = true;
  programs.neovim.enable = true;
  programs.neovim.defaultEditor = true;

  boot.binfmt.emulatedSystems = [ "aarch64-linux" ];

  system.stateVersion = "24.05";
  wsl = {
    enable = true;
    defaultUser = "noah";
    interop.register = true;
  };
}
