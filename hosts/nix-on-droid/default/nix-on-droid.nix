{
  config,
  lib,
  pkgs,
  ...
}:

{

  #common.basePackages.enable = false;


  # Simply install just the packages
  environment.packages = with pkgs; [
    # Some common stuff that people expect to have
    diffutils
    findutils
    utillinux
    tzdata
    hostname
    gnupg
    gnused
    gnutar
    bzip2
    gzip
    xz
    nushell

    # User added
    android-tools

    elmPackages.elm
    eza
    elixir
    fish
    gcc
    git
    gnugrep
    htop
    man
    #neovim
    openssh
    ps
    python3
    tmux
    tree
    unzip
    vim
    which
    zip
    nerd-fonts.hack
  ];

  terminal = {
    # Hack font
    font = "${pkgs.nerd-fonts.hack}/share/fonts/truetype/NerdFonts/Hack/HackNerdFontMono-Regular.ttf";
    # gruvbox colors
    colors = {
      background = "#1d2021";
      foreground = "#ebdbb2";
      color0 = "#282828";
      color1 = "#cc241d";
      color2 = "#98971a";
      color3 = "#d79921";
      color4 = "#458588";
      color5 = "#b16286";
      color6 = "#689d6a";
      color7 = "#a89984";
      color8 = "#928374";
      color9 = "#fb4934";
      color10 = "#b8bb26";
      color11 = "#fabd2f";
      color12 = "#83a598";
      color13 = "#d3869b";
      color14 = "#8ec07c";
      color15 = "#ebdbb2";
    };
  };

  user.shell = "${pkgs.fish}/bin/fish";

  # Backup etc files instead of failing to activate generation if a file already exists in /etc (nix-on-droid)
  environment.etcBackupExtension = ".bak";

  # Read the changelog before changing this value
  system.stateVersion = "23.11";

  # Set up nix for flakes
  nix.extraOptions = ''
    experimental-features = nix-command flakes
  '';

  # Set your time zone
  time.timeZone = "America/Los_Angeles";
}
