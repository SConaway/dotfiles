{ config, pkgs, ... }:

{
  imports =
    [
      ./hardware-configuration.nix
      ./qBittorrent-nox.nix
      ../../modules/common.nix
    ];

  networking.hostName = "qb";

  services.qemuGuest.enable = true;

  networking.wg-quick.interfaces.wg0.configFile = ./files/us-sjc.conf;

  environment.systemPackages = with pkgs; [
      qbittorrent-nox
  ];

  services.qbittorrent = {
      enable = true;
      openFirewall = true;
  };

  services.fstrim.enable = true;

  services.nfs.server.enable = true;
  services.nfs.server.exports = ''
    /mnt/share  192.168.8.0/24(rw,nohide,insecure,no_subtree_check)
  '';
  
  networking.firewall.allowedTCPPorts = [ 111 2049 20048 ];
}