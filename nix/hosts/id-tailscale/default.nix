{ config, pkgs, lib, ... }:

{
  imports =
    [
      ./hardware-configuration.nix
      ../../modules/common.nix
    ];

  networking.hostName = "id-tailscale";

  # Override time zone
  time.timeZone = lib.mkForce "America/Boise";

  # Original had NetworkManager commented out (disabled)
  networking.networkmanager.enable = lib.mkForce false;

  services.qemuGuest.enable = true;
  services.fstrim.enable = true;

  environment.systemPackages = with pkgs; [
      ethtool
      tailscale
  ];

  services.tailscale.enable = true;
  
  # Tailscale exit node / router settings
  boot.kernel.sysctl = {
    "net.ipv4.ip_forward" = 1;
    "net.ipv6.conf.all.forwarding" = 1;
  };
  
  systemd.services."ethtool-settings" = {
    description = "Configure custom ethtool offload settings";
    after = [ "network-online.target" ];
    wants = [ "network-online.target" ];
    serviceConfig = {
      Type = "oneshot";
      ExecStart = "${pkgs.ethtool}/bin/ethtool -K ens18 rx-udp-gro-forwarding on rx-gro-list off";
    };
    wantedBy = [ "multi-user.target" ];
  };
}