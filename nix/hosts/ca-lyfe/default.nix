{
  config,
  pkgs,
  lib,
  ...
}:

{
  imports = [
    ./hardware-configuration.nix
    ../../modules/linux.nix
    ../../modules/nvim.nix
  ];

  networking.hostName = "ca-lyfe";

  services.qemuGuest.enable = true;
  services.fstrim.enable = true;

  environment.systemPackages = with pkgs; [
    gh
  ];

  virtualisation.docker.enable = true;
  users.users.steven.extraGroups = [ "docker" ];

  services.tailscale.enable = true;

  # Disable for install...
  system.autoUpgrade.enable = lib.mkForce false;
  nix.gc.automatic = lib.mkForce false;
}
