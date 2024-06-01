{ config, lib, pkgs, nixvim, ... }:

{
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

    # User added
    elmPackages.elm
    eza
    fish
    git
    gnugrep
    htop
    man
    #neovim
    tmux
    unzip
    vim
    zip
  ];

  #user.shell = pkgs.fish;

  # Backup etc files instead of failing to activate generation if a file already exists in /etc (nix-on-droid)
  environment.etcBackupExtension = ".bak";

  # Backup home files instead of failing to activate generation if a file already exists in ~/ (home-manager)
  home-manager.backupFileExtension = "bak";
  home-manager.config =
    { pkgs, nixvim, ... }:
    {
      #system.os = "Nix-on-Droid";
      home.username = "nix-on-droid";
      home.homeDirectory = "/data/data/com.termux.nix/files/home";
      home.stateVersion = "23.11";

      programs.git = {
        enable = true;
        userName = "Noah Thornton";
        userEmail = "noahthornton15@gmail.com";
        difftastic.enable = true;
      };

      programs.home-manager.enable = true;

      #programs.fish.enable = true;

      programs.neovim = {
        enable = true;
        defaultEditor = true;
        viAlias = true;
        vimAlias = true;
        vimdiffAlias = true;
        plugins = with pkgs.vimPlugins; [
          #nvim-lspconfig
          #nvim-treesitter.withAllGrammars
          #plenary-nvim
          gruvbox-material
          #mini-nvim
        ];
      };
    };


  # Read the changelog before changing this value
  system.stateVersion = "23.11";

  # Set up nix for flakes
  nix.extraOptions = ''
    experimental-features = nix-command flakes
  '';

  # Set your time zone
  time.timeZone = "America/Los_Angeles";
}
