{
  config,
  pkgs,
  ...
}:

{
  imports = [
    ../../modules/shared.nix
    ../../modules/nvim.nix
    ../../modules/leaf.nix
  ];

  # requires `inputs.determinate.darwinModules.default` in flake.nix
  determinateNix.customSettings = {
    eval-cores = 8;
    warn-dirty = false;
  };

  # Auto upgrade nix package and the daemon service.
  # services.nix-daemon.enable = true;
  # disable nix-darwin upstream stuff:
  nix.enable = false;

  # nixpkgs.overlays = [
  #   (final: prev: {
  #     manifold = prev.manifold.overrideAttrs (old: {
  #       checkPhase = ''
  #         runHook preCheck
  #         test/manifold_test --gtest_filter=-Manifold.GetNormalLegacyContract:Boolean.Normals:BooleanComplex.InterpolatedNormals
  #         runHook postCheck
  #       '';
  #     });
  #   })
  # ];

  # allow unfree packages
  # nixpkgs.config.allowUnfreePredicate =
  #   pkg:
  #   builtins.elem (builtins.baseNameOf (builtins.toString pkg)) [
  #     "github-copilot-cli"
  #     "jellyfin-desktop"
  #     "discord"
  #     "docker-desktop"
  #     "spotify"
  #   ];

  # allow chrome due to 'insecure' updater
  # nixpkgs.config.permittedInsecurePackages = [
  #   "google-chrome-144.0.7559.97"
  # ];

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
  homebrew.onActivation.extraFlags = [
    "--force-cleanup"
  ];
  homebrew.onActivation.autoUpdate = true;
  homebrew.onActivation.upgrade = true;
  # homebrew.enableZshIntegration = true;
  # homebrew.enableBashIntegration = true;
  homebrew.taps = [
    "antoniorodr/memo"
    "darrylmorley/whatcable"
    "mediosz/tap"
    "steipete/tap"
  ];
  homebrew.brews = [
    "mas" # here for homebrew.masApps
    "antoniorodr/memo/memo"
    "steipete/tap/imsg"
    "steipete/tap/mcporter"
    "steipete/tap/remindctl"
  ];
  homebrew.casks = [
    "anki"
    "antigravity-cli"
    "bambu-studio"
    "calibre"
    "discord"
    "docker-desktop"
    "emojipedia"
    "handbrake-app"
    "imazing"
    "logitech-g-hub"
    "mediosz/tap/swipeaerospace"
    "minecraft"
    "musescore"
    "notion"
    "raspberry-pi-imager"
    "raycast"
    "rocket"
    "setapp"
    "surfshark"
    "tailscale-app"
    "lm-studio"
    "visual-studio-code"
    "vlc"
    "whatcable"
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
    # alacritty-graphics
    alacritty
    bun
    # claude-code-bin
    ccache
    github-copilot-cli
    ffmpeg
    firefox
    ghostty-bin
    google-chrome
    iina
    iterm2
    # jellyfin-desktop # qtwebengine-6.11.0 broken in nixpkgs
    keka
    melonds
    moreutils
    mosquitto
    nix-output-monitor
    openscad-unstable
    qbittorrent
    spotdl
    spotify
    utm
    uv
    wireshark
    # whatsapp-for-mac
  ];

  fonts.packages = [
    pkgs.nerd-fonts.meslo-lg
  ];

  # set environment variables
  environment.variables = {
    LANG = "en_US.UTF-8";
    LC_ALL = "en_US.UTF-8";
  };

  documentation.enable = true;
  documentation.doc.enable = true;
  documentation.info.enable = true;
  documentation.man.enable = true;
}
