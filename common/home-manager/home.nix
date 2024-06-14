{ config, pkgs, ... }:
{
  programs.home-manager.enable = true;

  # improved cat
  programs.bat.enable = true;

  # improved ls
  programs.eza = {
    enable = true;
    enableFishIntegration = true;

    # list git status if tracked
    git = true;

    # show icons next to items
    icons = true;
  };

  # user-friendly shell
  programs.fish = {
    enable = true;
    plugins = [
      {
        name = "fenv";
        src = pkgs.fishPlugins.foreign-env;
      }
    ];
    shellInit = "
      set -p fish_function_path ${pkgs.fishPlugins.foreign-env}/share/fish/vendor_functions.d\n
      fenv source ${config.home.profileDirectory}/etc/profile.d/hm-session-vars.sh > /dev/null
    ";
  };

  # fuzzy finder for shell history, files, etc
  programs.fzf = {
    enable = true;
    enableFishIntegration = true;
    # TODO tmux integration?
  };

  # version control
  programs.git = {
    enable = true;

    # improved difftool
    difftastic.enable = true;

    # TODO gitignore
    # TODO git include to include options, but need to modularize for work
    # TODO git username
    # TODO git useremail
  };

  # cpu and memory monitor
  programs.htop = {
    enable = true;
  };

  # vim type editor
  programs.neovim = {
    enable = true;
    defaultEditor = true;
    # TODO once vimrc is sorted ill enable this
    # vimAlias = true;
  };

  # its ssh...
  programs.ssh = {
    enable = true;
    # TODO modularize to use at work
  };

  # faster tldr
  programs.tealdeer = {
    enable = true;
    # TODO add alias to tldr
  };

  # command typo fixer
  programs.thefuck = {
    enable = true;
    enableFishIntegration = true;
  };

  # terminal multiplexer
  programs.tmux = {
    enable = true;
    mouse = true;
    # TODO plugins?
  };

  # youtube downloader
  programs.yt-dlp = {
    enable = true;
  };

  # TODO stuff to add later/explore
  # borgmatic
  # broot
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

  home.stateVersion = "24.05";
}
