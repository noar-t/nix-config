{
  description = "flake for nix-on-droid and nix-os devices/hostss";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-24.05";

    nix-on-droid = {
      url = "github:nix-community/nix-on-droid/release-23.11";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.home-manager.follows = "home-manager";
    };

    home-manager = {
      url = "github:nix-community/home-manager/release-24.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nix-darwin = {
      url = "github:LnL7/nix-darwin";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, nix-on-droid, home-manager, nix-darwin }: {
    nixosConfigurations = {
      # Home server
      rinsler = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [
          ./hosts/nixos/rinsler/configuration.nix
          # TODO replace with common module
          home-manager.nixosModules.home-manager
          {
            home-manager.useUserPackages = true;
            home-manager.useGlobalPkgs = true;
            home-manager.users.noah = import ./common/home-manager/home.nix;
            home-manager.backupFileExtension = "bak";
          }
        ];
      };

      # Gaming desktop
      raiden = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [
          ./hosts/nixos/raiden/configuration.nix
        ];
      };
    };

  # Work MacBook
  darwinConfigurations = {
      system = "aarch64-darwin";
      kodoma = nix-darwin.lib.darwinSystem {
        modules = [
        ./hosts/nix-darwin/configuration.nix
      ];
    };
  };

    # Galaxy Tab S8+
    nixOnDroidConfigurations.default = nix-on-droid.lib.nixOnDroidConfiguration {
      modules = [ ./hosts/nix-on-droid/default/nix-on-droid.nix ];
    };
  };
}
