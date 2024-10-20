# Edit this configuration file to define what should be installed on your system.  Help is available in the configuration.nix(5) man page and in the NixOS manual 
# (accessible by running `nixos-help`).

{
  config,
  lib,
  pkgs,
  ...
}:

{
  imports = [
    # Include the results of the hardware scan.
    ./hardware-configuration.nix
    ../../nix.nix
  ];

  # Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.systemd-boot.memtest86.enable = true;
  boot.loader.systemd-boot.extraInstallCommands = ''
    ${pkgs.gnused}/bin/sed -i 's/default nixos-generation-[0-9][0-9].conf/default @saved/g' /boot/loader/loader.conf
  '';
  boot.loader.efi.canTouchEfiVariables = true;
  boot.kernel.sysctl = {
    "vm.swappiness" = 10;
  };
  boot.tmp.useTmpfs = true;
  boot.supportedFilesystems = [ "ntfs" ];

  networking.hostName = "nixdesktop";
  time.hardwareClockInLocalTime = true;

  time.timeZone = "America/Los_Angeles";

  # Configure network proxy if necessary networking.proxy.default = "http://user:password@proxy:port/"; networking.proxy.noProxy = 
  # "127.0.0.1,localhost,internal.domain";

  # Select internationalisation properties. i18n.defaultLocale = "en_US.UTF-8"; console = {
  #   font = "Lat2-Terminus16"; keyMap = "us"; useXkbConfig = true; # use xkbOptions in tty.
  # };

  # Enable the X11 windowing system.
  services.xserver.enable = true;
  # DNS caching
  services.dnsmasq.enable = true;
  # SSD Trim
  services.fstrim.enable = true;

  # Enable the GNOME Desktop Environment.
  services.xserver.displayManager.gdm.enable = true;
  services.xserver.desktopManager.gnome.enable = true;
  services.xserver.displayManager.setupCommands = ''
    ${pkgs.xorg.xrandr}/bin/xrandr --output DP-0 --primary --rate 119.98 --mode 3440x1440 --pos 0x272 --output DP-2 --rate 59.88 --mode 1920x1200 --pos 3440x0 --rotate right
  '';

  # Piper mouse software
  services.ratbagd.enable = true;

  # Enable pipewire audio server
  hardware.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
  };

  # Nvidia settings follow
  hardware.graphics = {
    enable = true;
    extraPackages32 = with pkgs.pkgsi686Linux; [ libva ];
  };

  services.xserver.videoDrivers = [ "nvidia" ];

  hardware.nvidia = {
    modesetting.enable = true;
    # Use closed source driver since it works with suspend
    open = false;
    nvidiaSettings = true;
    package = config.boot.kernelPackages.nvidiaPackages.stable;
    forceFullCompositionPipeline = true;
    powerManagement.enable = true;
  };

  users.users.noah = {
    isNormalUser = true;
    extraGroups = [ "wheel" ];
    shell = pkgs.fish;
    packages =
      with pkgs;
      [
      ];
  };

  programs.fish.enable = true;
  programs.hyprland.enable = true;

  # List packages installed in system profile. To search, run: $ nix search wget
  environment.variables = {
    EDITOR = "nvim";
  };
  environment.systemPackages = with pkgs; [
    bitwarden
    bitwarden-cli
    comma
    discord
    dconf-editor
    easyeffects
    eza
    firefox
    fish
    gcc
    git
    glxinfo
    gnome-tweaks
    htop
    jdk17
    jetbrains.idea-community
    kitty
    lm_sensors
    mako # wayland notification daemon
    memtester
    neofetch
    neovim
    nix-index
    piper
    stress
    waybar
    tmux
    unigine-heaven
    vim
    watch
    wget
    wofi
  ];

  nixpkgs.config.allowUnfreePredicate =
    pkg:
    builtins.elem (lib.getName pkg) [
      "nvidia-x11"
      "nvidia-settings"
      "steam"
      "steam-original"
      "steam-run"
      "discord"
      "memtest86-efi"
      "unigine-heaven"
    ];

  programs.steam = {
    enable = true;
    remotePlay.openFirewall = true;
  };

  #  # Setup extensions to autoinstall in firefox
  #  programs.firefox.policies = ''
  #{
  #  "uBlock0@raymondhill.net": {
  #    "installation_mode": "force_installed",
  #    "install_url": "https://addons.mozilla.org/firefox/downloads/latest/ublock-origin/latest.xpi"
  #  },
  #  jid1-xUfzOsOFlzSOXg@jetpack - RES
  #  {00000f2a-7cde-4f20-83ed-434fcb420d71} - Imagus
  #  {446900e4-71c2-419f-a6a7-df9c091e268b} - Bitwarden
  #  addon@darkreader.org - DarkReader
  #  https://github.com/mozilla/policy-templates/blob/master/README.md has all the info
  #  can configure basically everything
  #}
  #  ''

  system.stateVersion = "24.05";
}
