{ config, pkgs, ... }:

{
  imports =
    [
      ./hardware-configuration.nix
      ../../modules/common.nix
    ];

  networking.hostName = "media";

  services.qemuGuest.enable = true;

  # Specific packages for media
  environment.systemPackages = with pkgs; [
      jellyfin
      jellyfin-web
      jellyfin-ffmpeg
      ffmpeg
      # plex
  ];

  # services.plex = {
  #   enable = false;
  #   openFirewall = false;
  # };

  services.jellyfin = {
    enable = true;
    openFirewall = true;
    cacheDir = "/mnt/jellyfin/cache/";
  };

  services.fstrim.enable = true;

  fileSystems."/mnt/share" = {
    device = "192.168.8.9:/mnt/share";
    fsType = "nfs";
  };
  
  services.nfs.server.enable = true;
  services.nfs.server.exports = ''
    /mnt/jellyfin/media  192.168.8.0/24(rw,nohide,insecure,no_subtree_check)
  '';
  
  networking.firewall.allowedTCPPorts = [ 111 2049 ];
}