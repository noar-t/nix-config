{
  pkgs,
  ...
}:
{
  # common packages i want on all systems
  environment.systemPackages = with pkgs; [
    bat # improved syntax aware cat
    comma # run a package without installing
    cowsay # a silly classic
    duf # fancy du + df
    erdtree # TESTING tree replacement
    eza # enhanced ls replacement
    fish # fish shell
    fzf # fuzzy searcher
    gcc # c/c++ compiler
    git # version control
    gotop # fancy resource viewer
    htop # process manager
    memtester # memory tester
    neofetch # terminal eye candy
    nix-index # search for which nix package provides a file
    stress # stress test
    silver-searcher # better grep
    tmux # terminal multiplexer
    watch # run commands at set interval
    wget # downloader
    yazi # file manager
  ];
}
