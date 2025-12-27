{ inputs }:
let
  defaultProfile = (import ../common/profile.nix);
  defaultHomeManagerConfig = import ../modules/home;
in
{

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

  mkStandaloneHomeManager =
    {
      profile ? defaultProfile,
      homeDirectory,
      system ? "x86_64-linux",
      extraHomeModules ? [ ],
      extraExtraSpecialArgs ? {},
    }:
    inputs.home-manager.lib.homeManagerConfiguration {
      pkgs = import inputs.nixpkgs {
        inherit system;
        config.allowUnfree = true;
      };
      extraSpecialArgs = {
        inherit
          inputs
          homeDirectory
          profile
          ;
        moduleMode = "HomeManager";
      } // extraExtraSpecialArgs;
      modules = [
        ../common
        {
          home.username = profile.username;
          home.homeDirectory = homeDirectory;
        }
        (import ../modules/home/home.nix { inherit extraHomeModules; })
      ];
    };

  mkNixOnDroid =
    {
      profile ? defaultProfile,
      extraModules ? [ ],
    }:
    let
      system = "aarch64-linux";
    in
    inputs.nix-on-droid.lib.nixOnDroidConfiguration {
      extraSpecialArgs = {
        inherit inputs profile;
      };
      pkgs = import inputs.nixpkgs {
        inherit system;
        config.allowUnfree = true;
      };
      modules = [
        ../hosts/nix-on-droid/default/nix-on-droid.nix
        {
          home-manager = {
            useGlobalPkgs = true;
            backupFileExtension = "bak";
            extraSpecialArgs = {
              inherit
                inputs
                profile
                ;
              moduleMode = "NixOS";
            };
            config = defaultHomeManagerConfig;
          };
        }
      ] ++ extraModules;
    };
}
