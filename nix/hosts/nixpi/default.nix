{
  config,
  pkgs,
  lib,
  ...
}:

{
  imports = [
    ../../modules/linux.nix
  ];

  networking.hostName = "nixpi";

  networking.networkmanager.enable = lib.mkForce false;
  networking.wireless = {
    enable = true;
    interfaces = [ "wlan0" ];
    networks."MyFi".pskRaw = "REDACTED_WIFI_PSK";
  };

  boot = {
    kernelPackages = lib.mkForce pkgs.linuxKernel.packages.linux_rpi4;
    initrd.availableKernelModules = [ "xhci_pci" "usbhid" "usb_storage" ];
    loader = {
      systemd-boot.enable = lib.mkForce false;
      efi.canTouchEfiVariables = lib.mkForce false;
      grub.enable = lib.mkForce false;
      generic-extlinux-compatible.enable = true;
    };
  };

  fileSystems."/" = {
    device = "/dev/disk/by-label/NIXOS_SD";
    fsType = "ext4";
    options = [ "noatime" ];
  };

  swapDevices = [ { device = "/var/lib/swapfile"; size = 4096; } ];

  hardware.enableRedistributableFirmware = true;

  # system.stateVersion = "23.11";
}
