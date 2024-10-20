# Do not modify this file!  It was generated by ‘nixos-generate-config’
# and may be overwritten by future invocations.  Please make changes
# to /etc/nixos/configuration.nix instead.
{
  config,
  lib,
  pkgs,
  modulesPath,
  ...
}:

{
  imports = [
    (modulesPath + "/installer/scan/not-detected.nix")
  ];

  boot.initrd.availableKernelModules = [
    "nvme"
    "xhci_pci"
    "ahci"
    "usbhid"
    "sd_mod"
  ];
  boot.initrd.kernelModules = [ "dm-snapshot" ];
  boot.kernelModules = [ "kvm-amd" ];
  boot.extraModulePackages = [ ];

  fileSystems."/" = {
    device = "/dev/disk/by-uuid/8230051c-b4f1-4503-a86c-845a7a877535";
    fsType = "btrfs";
  };

  fileSystems."/nix" = {
    device = "/dev/disk/by-uuid/7ca3e628-5dc3-489b-9d3c-4f1d6f657ae4";
    fsType = "btrfs";
  };

  fileSystems."/home" = {
    device = "/dev/disk/by-uuid/0d152955-62db-4b2b-8804-941179797ea4";
    fsType = "btrfs";
  };

  fileSystems."/boot" = {
    device = "/dev/disk/by-uuid/A770-DE85";
    fsType = "vfat";
  };

  fileSystems."/home/noah/Games" = {
    device = "/dev/disk/by-uuid/c2f46571-2187-4952-b7ed-4075b155b10f";
    fsType = "btrfs";
  };

  fileSystems."/home/noah/Win_Drives/C" = {
    device = "/dev/disk/by-uuid/8E16321F1632092B";
    fsType = "ntfs";
    options = [ "ro" ];
  };

  fileSystems."/home/noah/Win_Drives/Games" = {
    device = "/dev/disk/by-uuid/6002161E0215F9AC";
    fsType = "ntfs";
    options = [ "ro" ];
  };

  swapDevices = [
    { device = "/dev/disk/by-uuid/e49ba65a-c277-4b70-9dd2-d2e0b08c21d3"; }
  ];

  # Enables DHCP on each ethernet and wireless interface. In case of scripted networking
  # (the default) this is the recommended approach. When using systemd-networkd it's
  # still possible to use this option, but it's recommended to use it in conjunction
  # with explicit per-interface declarations with `networking.interfaces.<interface>.useDHCP`.
  networking.useDHCP = lib.mkDefault true;
  # networking.interfaces.enp4s0.useDHCP = lib.mkDefault true;
  # networking.interfaces.wlp5s0.useDHCP = lib.mkDefault true;

  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
  hardware.cpu.amd.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
}
