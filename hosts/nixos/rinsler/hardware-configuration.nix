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
    "xhci_pci"
    "ahci"
    "nvme"
    "usbhid"
    "sd_mod"
    "sr_mod"
  ];
  boot.initrd.kernelModules = [ "dm-snapshot" ];
  boot.kernelModules = [ "kvm-intel" ];
  boot.extraModulePackages = [ ];

  fileSystems."/" = {
    device = "/dev/disk/by-uuid/01610c9a-4219-4181-af7b-c87136226ce9";
    fsType = "btrfs";
  };

  fileSystems."/var/lib/docker/btrfs" = {
    device = "/var/lib/docker/btrfs";
    fsType = "none";
    options = [ "bind" ];
  };

  fileSystems."/home" = {
    device = "/dev/disk/by-uuid/240c5937-3064-49f4-86fd-614081e55b25";
    fsType = "btrfs";
  };

  fileSystems."/boot" = {
    device = "/dev/disk/by-uuid/411D-1A4F";
    fsType = "vfat";
  };

  fileSystems."/mnt/easystore" = {
    device = "/dev/disk/by-uuid/1eaa8ac0-2825-4950-a3ce-26fc5adcca9d";
    fsType = "btrfs";
  };

  swapDevices = [
    { device = "/dev/disk/by-uuid/99a37d24-66e4-4fa5-8b01-e2f2cbe0b548"; }
  ];

  # Enables DHCP on each ethernet and wireless interface. In case of scripted networking
  # (the default) this is the recommended approach. When using systemd-networkd it's
  # still possible to use this option, but it's recommended to use it in conjunction
  # with explicit per-interface declarations with `networking.interfaces.<interface>.useDHCP`.
  networking.useDHCP = lib.mkDefault true;
  # networking.interfaces.br-9d823cf6d39b.useDHCP = lib.mkDefault true;
  # networking.interfaces.docker0.useDHCP = lib.mkDefault true;
  # networking.interfaces.enp3s0.useDHCP = lib.mkDefault true;
  # networking.interfaces.veth075de8b.useDHCP = lib.mkDefault true;
  # networking.interfaces.veth2b43c79.useDHCP = lib.mkDefault true;
  # networking.interfaces.veth41a5822.useDHCP = lib.mkDefault true;
  # networking.interfaces.veth8b5cee3.useDHCP = lib.mkDefault true;
  # networking.interfaces.vethea5fc65.useDHCP = lib.mkDefault true;

  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
  powerManagement.cpuFreqGovernor = lib.mkDefault "powersave";
  hardware.cpu.intel.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
}
