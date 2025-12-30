{ inputs, ... }:
{
# Galaxy Tab S8+
  flake.nixOnDroidConfigurations.default = inputs.nix-on-droid.lib.nixOnDroidConfiguration {
    extraSpecialArgs = {
      inherit inputs;
    };

    pkgs = import inputs.nixpkgs {
      system = "aarch64-linux";
      config.allowUnfree = true;
    };

    modules = [
      ../hosts/nix-on-droid/default/nix-on-droid.nix
      {
        home-manager = {
          useGlobalPkgs = true;
          backupFileExtension = "bak";
          extraSpecialArgs = {
            inherit inputs;
          };
          config = ./home/home.nix;
        };
      }
    ];

  };
}
