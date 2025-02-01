{ inputs, platform, ... }:
{
  nix = {
    nixPath = [ "nixpkgs=${inputs.nixpkgs}" ];
    optimise.automatic = true;

    # Perform garbage collection weekly to save disk space
    #optimise.automatic = true;
    settings = {
      # You can also manually run nix-store --optimize
      #optimise.automatic = true;

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

    gc =
      {
        automatic = true;
      }
      // (
        if platform == "linux" then
          {

            dates = "weekly";
            options = "--delete-older-than 1w";
          }
        else
          {
            interval = {
              Hour = 3;
              Minute = 15;
              Weekday = 7;
            };
          }
      );
  };
}
