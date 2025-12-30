{
  inputs,
  ...
}:
{
  nix = {
    # package = pkgs.nix;

    nixPath = [ "nixpkgs=${inputs.nixpkgs}" ];

    # Perform garbage collection weekly to save disk space
    settings = {
      # You can also manually run nix-store --optimize
      experimental-features = [
        "nix-command"
        "flakes"
      ];

    };

    gc = {
      automatic = true;
      options = "--delete-older-than 1w";
      frequency = "weekly";
    };
  };
}
