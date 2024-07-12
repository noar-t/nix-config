{ config, pkgs, specialArgs, inputs, ... }:
{
  imports = [
    ./neovim.nix
    ./tmux.nix
    ./fish.nix
  ];

  home.stateVersion = "24.05";
  programs.home-manager.enable = true;
  # home-manager-help tool
  manual.html.enable = true;

  # improved cat
  programs.bat = {
    enable = true;
    config = {
      theme = "gruvbox-dark";
    };
  };

  # improved ls
  programs.eza = {
    enable = true;
    enableFishIntegration = true;

    # list git status if tracked
    git = true;

    # show icons next to items
    icons = true;
  };

  # fuzzy finder for shell history, files, etc
  programs.fzf = {
    enable = true;
    enableFishIntegration = true;
  };

  # version control
  programs.git = let
    inherit (specialArgs.profile) email;
  in {
    enable = true;

    # improved difftool
    difftastic.enable = true;

    userName = "Noah Thornton";
    userEmail = email;

    # TODO gitignore
    # TODO git include to include options, but need to modularize for work
  };

  # cpu and memory monitor
  programs.htop = {
    enable = true;
  };

  # its ssh...
  programs.ssh = {
    enable = true;
    # TODO modularize to use at work
  };

  # faster tldr
  programs.tealdeer = {
    enable = true;
    settings.updates.auto_update = true;
  };

  # command typo fixer
  programs.thefuck = {
    enable = true;
    enableFishIntegration = true;
  };

  # youtube downloader
  programs.yt-dlp = {
    enable = true;
  };

  # TODO stuff to add later/explore
  # borgmatic
  # chromium/firefox w/ extensions
  # fd
  # git-cliff -> generate changelog
  # jq
  # kitty
  # man -> isnt there a better man viewer?
  # noti -> script around processed
  # nnn -> filemanager
  # pazi -> file finder
  # pet -> snippet manager
  # pistol -> file previewer
  # pandoc -> document converter
  # rbw -> cli bitwarden client
  # sioyek -> white paper reader?
  # starship prompt -> is it better than default fish?
  # waybar -> bar only for wayland
  # wofi -> launcher for wayland
  # zathura -> pdf reader
  # flameshot -> screenshot
  #
  # MacOS
  # aerospace config
  # sketchybar config
  # janky borders config
  # jetbrains-remote
  # lots of darwin config option: targets.darwin...
  #
  # Generic Linux
  # targets.genericLinux.enable
  #
  # setup XDG?
  # editorconfig?
  # fonts?
  # gtk?
  #
  # home.file for all configs
}
