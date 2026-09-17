{
  config,
  modulesPath,
  pkgs,
  lib,
  inputs,
  ...
}:

{
  imports = [
    (modulesPath + "/virtualisation/proxmox-lxc.nix")
    ../../modules/linux.nix
    ../../modules/attic-push-linux.nix
    inputs.agenix.nixosModules.default
  ];

  networking.hostName = "ca-actual";

  # Container networking is handled by Proxmox; NetworkManager's
  # wpa_supplicant can't access /dev/rfkill in an unprivileged LXC.
  networking.networkmanager.enable = lib.mkForce false;

  nix.settings.sandbox = false;

  proxmoxLXC = {
    manageNetwork = false;
    manageHostName = true;
    privileged = false;
  };

  # Containers don't have their own bootloader; Proxmox supplies the kernel.
  boot.loader.systemd-boot.enable = lib.mkForce false;
  boot.loader.efi.canTouchEfiVariables = lib.mkForce false;

  services.fstrim.enable = false; # Let Proxmox host handle fstrim

  services.openssh.openFirewall = true;

  # Cache DNS lookups to improve performance
  services.resolved.settings.Resolve = {
    Cache = true;
    CacheFromLocalhost = true;
  };

  environment.systemPackages = with pkgs; [
    tailscale
    actual-server
  ];

  services.actual = {
    enable = true;
    openFirewall = true; # TODO: temporarily
  };

  services.tailscale.enable = true;

  system.stateVersion = lib.mkForce "26.11";
}
