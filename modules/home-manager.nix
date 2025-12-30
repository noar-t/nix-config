{ ... }:
{
  flake.homeModules = {
    alacritty = ../modules/home/alacritty.nix;
    bat = ../modules/home/bat.nix;
    eza = ../modules/home/eza.nix;
    fish = ../modules/home/fish.nix;
    fzf = ../modules/home/fzf.nix;
    ghostty = ../modules/home/ghostty.nix;
    git = ../modules/home/git.nix;
    htop = ../modules/home/htop.nix;
    hyprland = ../modules/home/hyprland.nix;
    neovim = ../modules/home/neovim.nix;
    nix = ../modules/home/nix.nix;
    ssh = ../modules/home/ssh.nix;
    tealdeer = ../modules/home/tealdeer.nix;
    tmux = ../modules/home/tmux.nix;
  };

  flake.homeConfigurations.default = (../modules/home.nix);
}
