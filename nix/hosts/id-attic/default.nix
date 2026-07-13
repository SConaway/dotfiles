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
    inputs.agenix.nixosModules.default
  ];

  networking.hostName = "id-attic";

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
  ];

  services.tailscale.enable = true;

  # Nix binary cache server.
  age.secrets.atticd-jwt.file = ../../secrets/id-attic/atticd-jwt.age;

  services.atticd = {
    enable = true;
    environmentFile = config.age.secrets.atticd-jwt.path;
    settings = {
      listen = "[::]:8080";
      jwt = { };
    };
  };

  networking.firewall.allowedTCPPorts = [ 8080 ];

  system.stateVersion = lib.mkForce "26.11";
}
