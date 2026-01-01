{ config, pkgs, ... }:

{
  imports = [ ../../modules/shared.nix ];

  # Auto upgrade nix package and the daemon service.
  # services.nix-daemon.enable = true;
  # disable nix-darwin upstream stuff: 
  nix.enable = false;

  # Create /etc/zshrc that loads the nix-darwin environment.
  programs.zsh.enable = true;  # default shell on catalina

  # Set your time zone.
  # time.timeZone = "America/Los_Angeles";

  # User Configuration
  users.knownUsers = [ "steven" ];
  users.users.steven = {
    name = "steven";
    home = "/Users/steven";
    uid = 501;
  };
  system.primaryUser = "steven";

  # System Defaults
  system.defaults = {
    dock = {
      # autohide = true;
      # mru-spaces = false;
    };
    finder = {
      AppleShowAllExtensions = true;
      FXPreferredViewStyle = "Nlsv";
    };
    NSGlobalDomain = {
      # AppleInterfaceStyle = "Dark";
      # "com.apple.swipescrolldirection" = false;
    };
    loginwindow = {
      LoginwindowText = ":)";
    };
  };

  # TouchID for Sudo:
  security.pam.services.sudo_local.touchIdAuth = true;
  
  # Homebrew Integration (Optional, but recommended)
  homebrew.enable = true;
  homebrew.casks = [ "zen" ];

  homebrew.masApps = {
    "Xcode" = 497799835;
    "Bitwarden" = 1352778147;
    "wBlock" = 6746388723;
  };

  # Used for backwards compatibility, please read the changelog before changing.
  # $ darwin-rebuild changelog
  system.stateVersion = 4;

  environment.systemPackages = with pkgs;
    [
      alacritty
      aerospace
      gemini-cli
      mas
      raycast
    ];

  fonts.packages = [
    pkgs.nerd-fonts.meslo-lg
  ];
}
