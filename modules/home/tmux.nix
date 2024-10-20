
{ config, pkgs, specialArgs, inputs, ... }:
{
  # terminal multiplexer
  programs.tmux = {
    enable = true;
    mouse = true;
    sensibleOnTop = true;
    keyMode = "vi";
    extraConfig = ''
      set -ag terminal-overrides ",xterm-256color:RGB"
    '';

    plugins = with pkgs.tmuxPlugins; [
      # Gruvbox colors
      gruvbox
      # Highlight when using prefix key
      # TODO add to status bar
      prefix-highlight
      # Fzf to manage tmux
      tmux-fzf
      # Fzf searching in buffer
      fuzzback
      # Pane navigation keybinds
      pain-control
      # Mouse configuration
      better-mouse-mode
    ];
  };
}
