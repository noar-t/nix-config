{ nixpkgs, inputs }: { arch, profile, extraModules ? [] }:
nixpkgs.lib.nixosSystem {
  system = arch;
  specialArgs = { inherit inputs profile; };
  modules = [
    inputs.home-manager.nixosModules.home-manager
    {
      home-manager.extraSpecialArgs = { inherit inputs profile; };
      home-manager.useUserPackages = true;
      home-manager.useGlobalPkgs = true;
      home-manager.backupFileExtension = "bak";
      home-manager.users.noah = import ../home-manager/home.nix;
    }
  ] ++ extraModules;
}

