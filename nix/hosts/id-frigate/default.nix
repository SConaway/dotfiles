{
  config,
  pkgs,
  lib,
  ...
}:

{
  imports = [
    ./hardware-configuration.nix
    ../../modules/common.nix
  ];

  networking.hostName = "frigate";
  networking.hostId = "0ef58ad2";

  # Override time zone
  time.timeZone = lib.mkForce "America/Boise";

  # Kernel - ZFS usually prefers LTS or specific versions, not latest.
  boot.kernelParams = [ "mitigations=off" ];
  boot.kernelPackages = lib.mkForce pkgs.linuxPackages;

  virtualisation.docker.enable = true;

  users.users.steven.extraGroups = [ "docker" ];

  environment.systemPackages = with pkgs; [
    docker
  ];

  services.qemuGuest.enable = true;
  services.fstrim.enable = true;

  services.zfs = {
    autoScrub.enable = true;
    trim.enable = true;
  };

  fileSystems."/mnt" = {
    device = "mntpool";
    fsType = "zfs";
    options = [
      "zfsutil"
    ];
  };

  networking.firewall.allowedTCPPorts = [
    5000
    8554
    8555
    1984
  ];
}
