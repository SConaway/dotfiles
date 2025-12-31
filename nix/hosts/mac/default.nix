{ config, pkgs, ... }:

{
  imports = [ ../../modules/shared.nix ];

  # Auto upgrade nix package and the daemon service.
  services.nix-daemon.enable = true;

  # Create /etc/zshrc that loads the nix-darwin environment.
  programs.zsh.enable = true;  # default shell on catalina

  # Set your time zone.
  time.timeZone = "America/Los_Angeles";

  # User Configuration
  users.users.steven = {
    name = "steven";
    home = "/Users/steven";
  };

  # System Defaults
  system.defaults = {
    dock = {
      # autohide = true;
      # mru-spaces = false;
    };
    finder = {
      AppleShowAllExtensions = true;
      FXPreferredViewStyle = "clmv";
    };
    NSGlobalDomain = {
      # AppleInterfaceStyle = "Dark";
      # "com.apple.swipescrolldirection" = false;
    };
  };
  
  # Homebrew Integration (Optional, but recommended)
  # homebrew.enable = true;
  # homebrew.casks = [ "firefox" "iterm2" ];

  # Used for backwards compatibility, please read the changelog before changing.
  # $ darwin-rebuild changelog
  system.stateVersion = 4;
}
