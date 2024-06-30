{ lib, pkgs, ... }:

{
  # Limit number of generations
  boot.loader.systemd-boot.configurationLimit = 5;

  # Perform garbage collection weekly to save disk space
  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 1w";
  };

  # You can also manually run nix-store --optimize
  nix.settings.auto-optimize-store = true;
}
