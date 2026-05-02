{ config, pkgs, inputs, ... }:

{
  imports = [
    ./hardware-configuration.nix
    # ./qBittorrent-nox.nix
    ../../modules/linux.nix
    inputs.agenix.nixosModules.default
  ];

  networking.hostName = "qb";

  services.qemuGuest.enable = true;

  age.secrets.wireguard.file = ../../secrets/ca-qb/wireguard.age;

  networking.wg-quick.interfaces.wg0.configFile = config.age.secrets.wireguard.path;

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

  networking.firewall.allowedTCPPorts = [
    111
    2049
    20048
  ];
}
