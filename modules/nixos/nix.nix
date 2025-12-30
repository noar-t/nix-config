{
  inputs,
  pkgs,
  ...
}:
{
  nixpkgs.config.allowUnfree = true;

  nix = {
    package = pkgs.nix;

    nixPath = [ "nixpkgs=${inputs.nixpkgs}" ];

    # Perform garbage collection weekly to save disk space
    settings = {
      # You can also manually run nix-store --optimize
      experimental-features = [
        "nix-command"
        "flakes"
      ];

      auto-optimise-store = true;
    };

    gc = {
      automatic = true;
      options = "--delete-older-than 1w";
      dates = "weekly";
    };

    optimise.automatic = true;
  };
}
