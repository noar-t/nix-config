{
  config,
  lib,
  pkgs,
  homeDirectory,
  username,
  ...
}:

{
  imports = [
    ../nix.nix
  ];

  system.stateVersion = 5;

  nix.extraOptions = ''
    extra-platforms = x86_64-darwin aarch64-darwin
  '';

  nixpkgs.hostPlatform = "aarch64-darwin";
  services.nix-daemon.enable = true;

  users.users.${username} = {
    home = homeDirectory;
    shell = pkgs.fish;
  };

  environment.systemPackages = with pkgs; [
    eza # ls with better defaults
    fselect # query files with sql-like syntax
    git # version control
    jq # json query tool
    neovim # modern vim
    tmux # terminal multiplexer
    # TODO replace with alias to `eza -T`
    tree # list directory tree
  ];

  programs = {
    fish.enable = true;
    zsh.enable = true;
  };

  environment.shells = [
    pkgs.bashInteractive
    pkgs.zsh
    pkgs.fish
  ];
  system.keyboard.remapCapsLockToControl = true;

  homebrew = {
    enable = true;
    onActivation = {
      autoUpdate = true;
      upgrade = true;
    };

    taps = [
      "nikitabobko/tap" # aerospace
      "felixkratz/formulae" # sketchybar + borders
    ];

    brews = [
      "sketchybar" # i3bar like alternative
      {
        name = "borders";
        start_service = true;
      }
    ];

    # TODO zap

    casks = [
      "aerospace" # tiling wm
      "alacritty" # gpu accelerated terminal
      "alfred" # spotlight replacement, dmenu-ish
      "bettertouchtool" # map gestures to handle workspaces
      "caffeine" # prevent mac from sleeping on demand
      "cheatsheet" # show all shorcuts for an app
      "ghostty" # terminal emulator
      "memoryanalyzer" # java heap dump viewer
      "flameshot" # gui screenshot tool
      "monitorcontrol" # control external monitor brightness
      "raycast" # better spotlight
      "shortcat" # click on things mouse-free
      "spotify" # music player
      "stats" # system bar resource monitor
      "visual-studio-code" # editor, do I even want this?
      "vlc" # media player
    ];
  };
}
