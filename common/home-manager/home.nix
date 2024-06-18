{ config, pkgs, specialArgs, ... }:
{

  home.stateVersion = "24.05";
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
    plugins = with pkgs.fishPlugins; [
      {
        name = "fenv";
        src = foreign-env.src;
      }
      {
        name = "fish-gruvbox";
        src = gruvbox.src;
      }
      {
        name = "autopair";
        src = autopair.src;
      }
      {
        name = "colored-man";
        src = colored-man-pages.src;
      }
      {
        name = "puffer";
        src = puffer.src;
      }
    ];

    shellAliases = {
      "cat" = "bat";
      "tree" = "eza -T";
    };

    interactiveShellInit = ''
      # Disable fish greetings
      set fish_greeting

      # Use vim keys
      fish_vi_key_bindings

      # Set prompt path to show more info
      set -g fish_prompt_pwd_dir_length 3
      set -g fish_prompt_pwd_full_dirs 3

      # Source homebrew
      if test -x /opt/homebrew/bin/brew
        eval (/opt/homebrew/bin/brew shellenv)
      end
    '';

    # use fenv to source nix path correctly
    shellInit = "
      set -p fish_function_path ${pkgs.fishPlugins.foreign-env}/share/fish/vendor_functions.d\n
      fenv source ${config.home.profileDirectory}/etc/profile.d/hm-session-vars.sh > /dev/null\n
    ";
  };

  # fuzzy finder for shell history, files, etc
  programs.fzf = {
    enable = true;
    enableFishIntegration = true;
    # TODO tmux integration?
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
}
