{ config, pkgs, inputs, ... }:

{
  imports = [
    ../../modules/shared.nix
    ../../modules/nvim.nix
  ];

  # requires `inputs.determinate.darwinModules.default` in flake.nix
  determinate-nix.customSettings = {
    eval-cores = 4;
  };

  # Auto upgrade nix package and the daemon service.
  # services.nix-daemon.enable = true;
  # disable nix-darwin upstream stuff:
  nix.enable = false;

  # Create /etc/zshrc that loads the nix-darwin environment.
  programs.zsh.enable = true; # default shell on catalina

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
      # https://mynixos.com/nix-darwin/option/system.defaults.dock.wvous-tl-corner
      wvous-tl-corner = 13; # top left hot corner: lock screen
      wvous-tr-corner = 10; # top right hot corner: sleep screen
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
  homebrew.onActivation.cleanup = "zap";
  homebrew.onActivation.upgrade = true;
  homebrew.taps = [ "mediosz/tap" ];
  homebrew.brews = [
    "mas" # here for homebrew.masApps
  ];
  homebrew.casks = [
    "bambu-studio"
    "calibre"
    "emojipedia"
    "handbrake-app"
    "mediosz/tap/swipeaerospace"
    "minecraft"
    "notion"
    "rocket"
    "setapp"
    "surfshark"
    "tailscale-app"
    "vlc"
    "whatsapp"
    "zen"
  ];
  homebrew.masApps = {
    "Bitwarden" = 1352778147;
    "wBlock" = 6746388723;
    "Xcode" = 497799835;
  };

  # Used for backwards compatibility, please read the changelog before changing.
  # $ darwin-rebuild changelog
  system.stateVersion = 6;

  environment.systemPackages = with pkgs; [
    aerospace
    alacritty
    ccache
    inputs.colmena.packages.${pkgs.system}.colmena
    github-copilot-cli
    discord
    docker
    ffmpeg
    gemini-cli
    google-chrome
    iina
    jellyfin-desktop
    keka
    mosquitto
    musescore
    openscad-unstable
    qbittorrent
    raycast
    spotify
    utm
    vscode
    # whatsapp-for-mac
  ];

  fonts.packages = [
    pkgs.nerd-fonts.meslo-lg
  ];
}
