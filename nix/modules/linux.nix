{ config, pkgs, ... }:

{
  imports = [ ./shared.nix ];

  # Bootloader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # Use latest kernel.
  boot.kernelPackages = pkgs.linuxPackages_latest;

  # Enable networking
  networking.networkmanager.enable = true;

  # Set your time zone.
  time.timeZone = "America/Los_Angeles";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.UTF-8";

  i18n.extraLocaleSettings = {
    LC_ADDRESS = "en_US.UTF-8";
    LC_IDENTIFICATION = "en_US.UTF-8";
    LC_MEASUREMENT = "en_US.UTF-8";
    LC_MONETARY = "en_US.UTF-8";
    LC_NAME = "en_US.UTF-8";
    LC_NUMERIC = "en_US.UTF-8";
    LC_PAPER = "en_US.UTF-8";
    LC_TELEPHONE = "en_US.UTF-8";
    LC_TIME = "en_US.UTF-8";
  };

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.steven = {
    isNormalUser = true;
    description = "steven";
    extraGroups = [
      "networkmanager"
      "wheel"
    ];
    # Packages moved to shared.nix
    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIHa5ZkCZmgH2SA1S1BolZMm7172xb0AlOzkG1iYYJ32R"
    ];
    shell = pkgs.zsh;
  };

  # requires NixOS
  programs.command-not-found.enable = true;

  # Link Atuin config using systemd-tmpfiles (hack for non-Home-Manager setups)
  # Ensures ~/.config/atuin/config.toml exists and points to our managed file
  systemd.tmpfiles.rules = [
    "L+ /home/steven/.config/atuin/config.toml - - - - ${pkgs.writeText "atuin.toml" (builtins.readFile ./files/atuin.toml)}"
    "L+ /home/steven/.p10k.zsh - - - - ${pkgs.writeText "p10k.zsh" (builtins.readFile ./files/p10k.zsh)}"
    "f /home/steven/.zshrc 0644 steven users - # Managed by NixOS"
  ];

  # Enable the OpenSSH daemon.
  services.openssh.enable = true;

  # Allow passwordless sudo for wheel group (fixes deployment automation)
  security.sudo.wheelNeedsPassword = false;

  # Allow wheel users to manage nix (fixes 'untrusted user' warnings)
  nix.settings.trusted-users = [
    "root"
    "@wheel"
  ];

  # Automatically install system updates daily
  system.autoUpgrade = {
    enable = true;
    allowReboot = true;
    dates = "11:00";
  };

  # Nix Garbage Collection
  nix.gc = {
    automatic = true;
    options = "--delete-older-than 7d";
    dates = "daily";
  };

  documentation.man.generateCaches = true;

  system.stateVersion = "25.05";
}
