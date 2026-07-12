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
    options = [ "zfsutil" ];
  };

  # mntpool holds Frigate recordings/clips: write-once, read-almost-never,
  # already-compressed video. Skip ARC data caching and compression so it
  # doesn't crowd out RAM or burn CPU for no benefit.
  #
  # This must run after mntpool is actually imported, so it's a systemd
  # service ordered after the /mnt mount rather than a system.activationScript
  # -- activation scripts can run as early as initrd, before secondary pools
  # (anything but the root pool) are imported.
  systemd.services.zfsFrigateTuning = {
    description = "Tune mntpool ZFS properties for Frigate recordings";
    wantedBy = [ "multi-user.target" ];
    after = [ "mnt.mount" ];
    requires = [ "mnt.mount" ];
    serviceConfig.Type = "oneshot";
    script = ''
      ${config.boot.zfs.package}/bin/zfs set primarycache=metadata mntpool
      ${config.boot.zfs.package}/bin/zfs set secondarycache=metadata mntpool
      ${config.boot.zfs.package}/bin/zfs set atime=off mntpool
      ${config.boot.zfs.package}/bin/zfs set logbias=throughput mntpool
      ${config.boot.zfs.package}/bin/zfs set recordsize=1M mntpool
      ${config.boot.zfs.package}/bin/zfs set compression=off mntpool
    '';
  };

  systemd.packages = [
    (pkgs.writeTextDir "lib/systemd/system/mnt.mount.d/timeout.conf" ''
      [Mount]
      TimeoutSec=600
    '')
  ];

  networking.firewall.allowedTCPPorts = [
    5000
    8554
    8555
    1984
  ];
}
