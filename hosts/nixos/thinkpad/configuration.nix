{ pkgs, inputs, ... }:

{
  imports = [
    ./hardware-configuration.nix
    inputs.nix-hardware.nixosModules.lenovo-thinkpad-t440s
  ];

  # Bootloader
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  networking.hostName = "thinkpad"; # Define your hostname.
  # networking.wireless.enable = true; # Enables wireless support via wpa_supplicant.

  # Enable networking
  networking.networkmanager.enable = true;

  # Set your time zone.
  time.timeZone = "America/Los_Angeles";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.UTF-8";

  i18n.extraLocaleSettings = {
    LC_ADDRESS = "en_US.UTF-8";
    LC_IDENTIFICATION = "en_US.UTF-8";
    LC_MEASUREMENT = "en_US.UTF-8";
    LC_MONETARY = "en_US.UTF-8";
    LC_NAME = "en_US.UTF-8";
    LC_NUMERIC = "en_US.UTF-8";
    LC_PAPER = "en_US.UTF-8";
    LC_TELEPHONE = "en_US.UTF-8";
    LC_TIME = "en_US.UTF-8";
  };

  # X Server SEtup
  services.xserver = {
    enable = true;

    # Configure keymap in X11
    xkb = {
      layout = "us";
      options = "ctrl:nocaps";
      variant = "";
    };
  };

  # Enable desktop manager and display manager
  services.desktopManager.gnome.enable = true;
  services.displayManager.gdm.enable = true;

  # Enable CUPS to print documents.
  services.printing.enable = true;

  programs.fish.enable = true;

  users.users.noah = {
    isNormalUser = true;
    description = "Noah";
    shell = pkgs.fish;
    extraGroups = [
      "networkmanager"
      "docker"
      "wheel"
    ];
    packages = with pkgs; [
      firefox
    ];
  };

  virtualisation.docker.enable = true;

  environment.variables.EDITOR = "vim";
  # List packages installed in system profile. To search, run: $ nix search wget
  environment.systemPackages = with pkgs; [
    docker
    docker-compose
    claude-code
    claude-monitor
    unzip
    zip
    git
    htop
    tmux
    vim
    wget # Do not forget to add an editor to edit configuration.nix! The Nano editor is also installed by default. wget
    chromium
    jetbrains.idea
    inputs.cytrace-kiwi-flake.packages.${pkgs.system}.default
  ];

  # This value determines the NixOS release from which the default settings for stateful data, like file locations and database versions on your system were taken. It‘s perfectly fine and
  # recommended to leave this value at the release version of the first install of this system. Before changing this value read the documentation for this option (e.g. man
  # configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "24.05"; # Did you read the comment?

}
