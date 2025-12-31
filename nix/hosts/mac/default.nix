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

  # Atuin Config (Darwin doesn't use systemd-tmpfiles, so we use activation scripts or home-manager)
  # For now, we will just rely on the user manually linking or using the shared zsh config which is robust.
  # But we can try to write the file using activation scripts.
  system.activationScripts.postActivation.text = ''
    # Simple link for atuin if it doesn't exist
    mkdir -p /Users/steven/.config/atuin
    ln -sf ${pkgs.writeText "atuin.toml" (builtins.readFile ../../modules/files/atuin.toml)} /Users/steven/.config/atuin/config.toml

    # Link p10k.zsh
    ln -sf ${pkgs.writeText "p10k.zsh" (builtins.readFile ../../modules/files/p10k.zsh)} /Users/steven/.p10k.zsh
  '';

  # Used for backwards compatibility, please read the changelog before changing.
  # $ darwin-rebuild changelog
  system.stateVersion = 4;
}
