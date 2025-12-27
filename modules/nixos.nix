{ inputs, ... }:
{
  flake =
    let
      defaultProfile = (import ../common/profile.nix);
      defaultHomeManagerConfig = import ../modules/home;

      mkNixOS =
        {
          hostName,
          profile ? defaultProfile,
          system ? "x86_64-linux",
        }:
        inputs.nixpkgs.lib.nixosSystem {
          specialArgs = {
            inherit inputs profile;
            moduleMode = "NixOS";
          };
          modules = [
            { nixpkgs.hostPlatform = system; }
            ../hosts/nixos/${hostName}/configuration.nix
            ../common
            inputs.home-manager.nixosModules.home-manager
            {
              home-manager = {
                extraSpecialArgs = {
                  moduleMode = "NixOS";
                  inherit
                    inputs
                    profile
                    ;
                };
                useUserPackages = true;
                useGlobalPkgs = true;
                backupFileExtension = "bak";
                users.${profile.username} = defaultHomeManagerConfig;
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

      # Export individual NixOS modules for reuse
      nixosModules = {
        # Export entire common directory
        common = ../common;

        # Export individual common modules
        base-packages = ../common/packages/base-packages.nix;
        gui-packages = ../common/packages/gui-packages.nix;
        nix-config = ../common/nix.nix;
        profile = ../common/profile.nix;

        # NixOS-specific modules
        auto-apply-flake-update = ../modules/nixos/auto-apply-flake-update.nix;
      };
    };
}
