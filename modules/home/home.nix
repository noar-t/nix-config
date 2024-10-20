{
  extraHomeModules ? [ ],
}:
{
  pkgs,
  ...
}:
{
  imports = [
    ./bat.nix
    ./eza.nix
    ./fish.nix
    ./fzf.nix
    ./git.nix
    ./htop.nix
    ./hyprland.nix
    ./neovim.nix
    ./ssh.nix
    ./tealdeer.nix
    ./thefuck.nix
    ./tmux.nix
    ./yt-dlp.nix
  ] ++ extraHomeModules;

  home.stateVersion = "24.05";
  home.sessionVariables.EDITOR = "nvim";
  home.packages = with pkgs; [
    erdtree
    silver-searcher
    duf
  ];

  programs.home-manager.enable = true;

  # home-manager-help tool, use command "home-manager-help"
  manual.html.enable = true;

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
}
