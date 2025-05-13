{
  extraHomeModules ? [ ],
}:
{
  pkgs,
  ...
}:
let
  moduleFiles = builtins.filter (
    file: file != "home.nix" && builtins.match ".*\\.nix$" file != null
  ) (builtins.attrNames (builtins.readDir ../modules/home));

  homeModules = builtins.listToAttrs (
    builtins.map (file: {
      name = builtins.replaceStrings [ ".nix" ] [ "" ] file;
      value = import ../modules/home/${file};
    }) moduleFiles
  );
in
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
    ./neovim.nix
    ./ssh.nix
    ./tealdeer.nix
    ./tmux.nix
  ] ++ extraHomeModules;

  home.stateVersion = "24.05";
  home.packages = with pkgs; [
    erdtree # tree replacement
    gum # Tool for interactive CLI
    silver-searcher # Like grep but fast
    duf # Disk usage tool
    jq # JSON CLI tool
  ];

  programs.home-manager.enable = true;

  # home-manager-help tool, use command "home-manager-help"
  manual.html.enable = true;

  home.sessionVariables = {
    MANPAGER = "nvim +Man!";
    EDITOR = "nvim";
    BROWSER = "google-chrome";
  };

  # TODO stuff to add later/explore
  # borgmatic
  # chromium/firefox w/ extensions
  # fd
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

  # NOTE: set "targets.genericLinux.enable" when on a non-NixOS host

  # setup XDG?
  # editorconfig?
  # gtk?
}
