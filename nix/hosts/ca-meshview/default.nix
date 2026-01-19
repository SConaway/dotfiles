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
  ];

  networking.hostName = "ca-meshview";

  services.qemuGuest.enable = true;

  # Desktop
  services.xserver.enable = true;
  services.xserver.displayManager.lightdm.enable = true;
  services.desktopManager.budgie.enable = true;

  # Extra user packages
  users.users.steven.packages = with pkgs; [
    lazygit
    delta
    bootterm
  ];

  # Extra system packages
  environment.systemPackages = with pkgs; [
    go
    gnumake
    gcc
  ];

  programs.nix-ld.enable = true;
  programs.nix-ld.libraries = with pkgs; [
    stdenv.cc.cc.lib
  ];

  networking.firewall.allowedTCPPorts = [ 8081 ];

  # Disabled in original
  system.autoUpgrade.enable = lib.mkForce false;
  nix.gc.automatic = lib.mkForce false;
}
