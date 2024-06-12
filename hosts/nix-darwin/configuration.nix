{ config, lib, pkgs, ... }:

{
  nixpkgs.hostPlatform = "aarch64-darwin";
  services.nix-daemon.enable = true;

  users.users.noahthor = {
    home = "/Users/noahthor";
  };


  environment.systemPackages = with pkgs; [
    eza     # ls with better defaults
	fselect # query files with sql-like syntax
	git     # version control
	jq      # json query tool
	neovim  # modern vim
	tmux    # terminal multiplexer
	# TODO replace with alias to `eza -T`
	tree    # list directory tree
  ];

  programs = {
	fish.enable = true;
    zsh.enable = true;
  };

  nix.extraOptions = ''
    auto-optimise-store = true
	experimental-features = nix-command flakes
	extra-platforms = x86_64-darwin aarch64-darwin
  '';

  homebrew = {
    enable = true;

	taps = [
	  "nikitabobko/tap"     # aerospace
	  "felixkratz/formulae" # sketchybar
	];

	brews = [
	  "sketchybar" # i3bar like alternative
	];

	# TODO zap

    casks = [
	  "aerospace"          # tiling wm
	  "alacritty"          # gpu accelerated terminal
	  "alfred"             # spotlight replacement, dmenu-ish
	  "bettertouchtool"    # map gestures to handle workspaces
	  "caffeine"           # prevent mac from sleeping on demand
	  "cheatsheet"         # show all shorcuts for an app
	  "flameshot"          # gui screenshot tool
	  "monitorcontrol"     # control external monitor brightness
	  "shortcat"           # click on things mouse-free
	  "spotify"            # music player
	  "stats"              # system bar resource monitor
	  "visual-studio-code" # editor, do I even want this?
	  "vlc"                # media player
	];
  };
}
