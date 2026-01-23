{ inputs, ... }:
{
  flake =
    let
      mkNixOS =
        {
          hostName,
          system ? "x86_64-linux",
        }:
        inputs.nixpkgs.lib.nixosSystem {
          specialArgs = {
            inherit inputs;
          };
          modules = [
            { nixpkgs.hostPlatform = system; }
            ../hosts/nixos/${hostName}/configuration.nix
            ../modules/nixos/base-packages.nix
            ../modules/nixos/gui-packages.nix
            ../modules/nixos/nix.nix
            ../modules/nixos/disk-monitor.nix
            ../modules/nixos/failed-unit-notifier.nix
            inputs.home-manager.nixosModules.home-manager
            {
              home-manager = {
                extraSpecialArgs = {
                  inherit
                    inputs
                    ;
                };
                useUserPackages = true;
                useGlobalPkgs = true;
                backupFileExtension = "bak";
                users.noah = ../modules/home/home.nix;
              };
            }
          ];
        };
    in
    {
      # NixOS system configurations
      nixosConfigurations = builtins.listToAttrs (
        map (hostName: {
          name = hostName;
          value = mkNixOS {
            inherit hostName;
          };
        }) (builtins.attrNames (builtins.readDir ../hosts/nixos))
      );
    };
}
