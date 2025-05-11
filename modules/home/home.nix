{
  extraHomeModules ? [ ],
}:
{
  pkgs,
  ...
}:
{
  imports = [
    ./alacritty.nix
    ./bat.nix
    ./eza.nix
    ./fish.nix
    ./fzf.nix
    ./ghostty.nix
    ./git.nix
    ./htop.nix
    ./hyprland.nix
    ./neovide.nix
    ./neovim.nix
    ./ssh.nix
    ./tealdeer.nix
    ./thefuck.nix
    ./tmux.nix
    ./yt-dlp.nix
  ] ++ extraHomeModules;

  home.stateVersion = "24.05";
  home.sessionVariables.EDITOR = "nvim";
  home.sessionVariables.MANPAGER = "nvim +Man!";
  home.packages = with pkgs; [
    erdtree
    gum
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
  # jq
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

  # Generic Linux
  # targets.genericLinux.enable
  #
  # setup XDG?
  # editorconfig?
  # fonts?
  # gtk?
}
