{ inputs }: {

  mkNixOS = {
    profile,
    arch ? "x86_64-linux",
    extraModules ? [],
  }: inputs.nixpkgs.lib.nixosSystem {
    system = arch;
    specialArgs = { 
      inherit inputs profile;
      moduleMode = "NixOS";
    };
    modules = [
      inputs.home-manager.nixosModules.home-manager
      {
        home-manager.extraSpecialArgs = { inherit inputs profile; };
        home-manager.useUserPackages = true;
        home-manager.useGlobalPkgs = true;
        home-manager.backupFileExtension = "bak";
        home-manager.users.noah = import ../common/home-manager/home.nix;
      }
      ../common
    ] ++ extraModules;
  };

  mkStandaloneHomeManager = {
    profile,
    arch ? "x86_64-linux",
    extraModules ? []
  }: inputs.home-manager.lib.homeManagerConfiguration {
    pkgs = (import inputs.nixpkgs { system = arch; });
    extraSpecialArgs = {
      inherit inputs profile; 
      moduleMode = "HomeManager";
    };
    modules = [
      ../common
      {
        home.username = profile.username;
        home.homeDirectory = profile.homeDirectory;
      }
      ../common/home-manager/home.nix
    ] ++ extraModules;
  };

  
  mkDarwin = {
    profile,
    arch ? "aarch64-darwin",
    extraModules ? []
  }: inputs.nix-darwin.lib.darwinSystem {
    system = arch;
    specialArgs = { 
      inherit inputs profile;
      moduleMode = "NixOS";
    };
    modules = [
      ../common
      ../hosts/nix-darwin/configuration.nix
    ] ++ extraModules;
  };

  mkNixOnDroid = {
    profile,
    extraModules ? []
  }: inputs.nix-on-droid.lib.nixOnDroidConfiguration {
    extraSpecialArgs = {
      inherit inputs profile;
      moduleMode = "NixOS";
    };
    modules = [
      ../common
      ../hosts/nix-on-droid/default/nix-on-droid.nix
      {
        home-manager.useGlobalPkgs = true;
        home-manager.backupFileExtension = "bak";
        home-manager.extraSpecialArgs = { inherit inputs profile; };
        home-manager.config = ../common/home-manager/home.nix;
      }
    ] ++ extraModules;
  };
}

