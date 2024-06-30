{ lib, pkgs, ... }:

{
  # Limit number of generations
  boot.loader.systemd-boot.configurationLimit = 5;

  # Perform garbage collection weekly to save disk space
  nix = {
    optimise.automatic = true;
    # You can also manually run nix-store --optimize
    settings.auto-optimise-store = true;

    gc = {
      automatic = true;
      dates = "weekly";
      options = "--delete-older-than 1w";
    };
  };

}
