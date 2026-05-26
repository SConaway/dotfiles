{
  config,
  pkgs,
  lib,
  ...
}:

{
  imports = [
    ./hardware-configuration.nix
    ./disko.nix
    ../../modules/linux.nix
  ];

  networking.hostName = "small";
  networking.networkmanager.enable = lib.mkForce false;

  networking.interfaces.enp3s0.ipv4.addresses = [{
    address = "208.87.130.161";
    prefixLength = 24;
  }];
  networking.defaultGateway = "208.87.130.1";
  networking.nameservers = [ "1.1.1.1" "8.8.8.8" ];

# BIOS boot — no EFI on this VPS
  boot.loader.systemd-boot.enable = lib.mkForce false;
  boot.loader.efi.canTouchEfiVariables = lib.mkForce false;
  boot.loader.grub.enable = true;

  services.qemuGuest.enable = true;
  services.fstrim.enable = true;

  services.tailscale.enable = true;

  system.autoUpgrade.enable = lib.mkForce false;
  nix.gc.automatic = lib.mkForce false;
}
