{ config, pkgs, lib, specialArgs, ... }:
let
  # moduleMode = "NixOS" OR "HomeManager"
  moduleMode = specialArgs.moduleMode;
  cfg = config.common.basePackages;
  basePackages = with pkgs; [
    bat             # improved syntax aware cat
    comma           # run a package without installing
    cowsay          # a silly classic
    duf             # fancy du + df
    erdtree         # TESTING tree replacement
    eza             # enhanced ls replacement
    fish            # fish shell
    fzf             # fuzzy searcher
    gcc             # c/c++ compiler
    git             # version control
    gotop           # fancy resource viewer
    htop            # process manager
    iotop-c         # I/O resource usage viewer
    lm_sensors      # temperature and other sensor data viewer
    memtester       # memory tester
    neofetch        # terminal eye candy
    neovim          # better vim
    nix-index       # search for which nix package provides a file
    stress          # stress test
    silver-searcher # better grep
    tmux            # terminal multiplexer
    watch           # run commands at set interval
    wget            # downloader
    yazi            # file manager
  ];
in {
  options.common.basePackages = {
    enable = lib.mkOption {
      default = true;
      example = true;
      description = "Whether to enable my standard cli packages";
      type = lib.types.bool;
    };
  };

  config = lib.mkIf cfg.enable (
    if (moduleMode == "NixOS") 
    # Used as NixOS module
    then { environment.systemPackages = basePackages; }
    # Used as Home-Manager module
    else { home.packages = basePackages; }
  );
}
