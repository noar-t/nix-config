{
  description = "flake for nix-on-droid and nix-os devices/hosts";

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
  };

  outputs = { self, nixpkgs, nix-on-droid, home-manager }: {
    nixosConfigurations = {
      # Home server
      rinsler = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [
          ./host/nixos/rinsler/configuration.nix
        ];
      };

      # Gaming desktop
      raiden = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [
          ./host/nixos/raiden/configuration.nix
        ];
      };
    };

    # Galaxy Tab S8+
    nixOnDroidConfigurations.default = nix-on-droid.lib.nixOnDroidConfiguration {
      modules = [ ./host/nix-on-droid/default/nix-on-droid.nix ];
    };
  };
}
