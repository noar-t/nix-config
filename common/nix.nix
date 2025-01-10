{ inputs, ... }:
{
  nix = {
    nixPath = [ "nixpkgs=${inputs.nixpkgs}" ];

    # Perform garbage collection weekly to save disk space
    optimise.automatic = true;
    settings = {
      # You can also manually run nix-store --optimize
      auto-optimise-store = true;

      experimental-features = [
        "nix-command"
        "flakes"
      ];

      substituters = [
        # Hyprland
        "https://hyprland.cachix.org"
        # Ghostty
        "https://ghostty.cachix.org"
      ];

      trusted-public-keys = [
        # Hyprland
        "hyprland.cachix.org-1:a7pgxzMz7+chwVL3/pzj6jIBMioiJM7ypFP8PwtkuGc="
        # Ghostty
        "ghostty.cachix.org-1:QB389yTa6gTyneehvqG58y0WnHjQOqgnA+wBnpWWxns="
      ];
    };

    gc = {
      automatic = true;
      dates = "weekly";
      options = "--delete-older-than 1w";
    };
  };
}
