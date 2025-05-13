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
      platform ? "linux",
    }:
    inputs.nixpkgs.lib.nixosSystem {
      system = system;
      specialArgs = {
        inherit inputs profile platform;
        moduleMode = "NixOS";
      };
      modules = [
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
                system
                platform
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
      platform ? "linux",
      extraHomeModules ? [ ],
    }:
    inputs.home-manager.lib.homeManagerConfiguration {
      pkgs = (import inputs.nixpkgs { inherit system; });
      extraSpecialArgs = {
        inherit
          inputs
          homeDirectory
          profile
          platform
          system
          ;
        moduleMode = "HomeManager";
      };
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
      platform = "linux";
    in
    inputs.nix-on-droid.lib.nixOnDroidConfiguration {
      extraSpecialArgs = {
        inherit inputs profile platform;
      };
      pkgs = import inputs.nixpkgs { inherit system; };
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
                platform
                system
                ;
              moduleMode = "NixOS";
            };
            config = defaultHomeManagerConfig;
          };
        }
      ] ++ extraModules;
    };
}
