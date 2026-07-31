{
  config,
  pkgs,
  inputs,
  ...
}:

{
  imports = [
    ../../modules/shared.nix
    ../../modules/nvim.nix
    ../../modules/leaf.nix
    ../../modules/attic-push-darwin.nix
    ../../modules/man-cache-darwin.nix
    inputs.agenix.darwinModules.default
  ];

  # No sshd host keys on this personal machine; decrypt secrets with the
  # same personal key already used as the "user" recipient in secrets.nix.
  age.identityPaths = [ "/Users/steven/.ssh/id_ed25519" ];

  # requires `inputs.determinate.darwinModules.default` in flake.nix
  determinateNix.customSettings = {
    eval-cores = 8;
    warn-dirty = false;
    accept-flake-config = true;

    # Allow steven to manage nix directly and have flake nixConfig overrides
    # (e.g. colmena.cachix.org below) honored (fixes 'untrusted user'
    # warnings), matching every other host in the fleet (modules/linux.nix).
    trusted-users = [
      "root"
      "steven"
    ];

    # Pull-through caches for source-built packages (colmena, zsh-patina, etc.)
    # served by id-attic over Tailscale, and colmena's own binary cache. Set
    # here (rather than in ~/.config/nix/nix.conf) so they're part of the
    # daemon's own trusted config regardless of the client-override trust
    # check above. extra- so it adds to (rather than replaces) the default
    # cache.nixos.org substituter.
    extra-substituters = [
      "http://id-attic:8080/homelab"
      "https://colmena.cachix.org"
    ];
    extra-trusted-public-keys = [
      "homelab:yCQlAzmcPZfjWhjm/W2jlZZCxhFZGVQjAELYLhPbNCk="
      "colmena.cachix.org-1:7BzpDnjjH8ki2CT3f6GdOk7QAzPOl+1t3LvTLXqYcSg="
    ];
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

  # Darwin build fixes for qt6.qtwebengine, unmerged upstream as of writing
  # (nixpkgs#520445, nixpkgs#547302). Re-enables jellyfin-desktop, which was
  # disabled below due to qtwebengine-6.11.0 being broken on Darwin.
  nixpkgs.overlays = [
    (final: prev: {
      qt6 = prev.qt6.overrideScope (
        qt6final: qt6prev: {
          qtwebengine = qt6prev.qtwebengine.overrideAttrs (old: {
            patches =
              old.patches
              ++ final.lib.optionals final.stdenv.hostPlatform.isDarwin [
                # Strips a relative -isysroot that chromium's build emits into
                # the link rsp files; without it the linker resolves it from
                # the wrong cwd and fails with "framework not found
                # CoreFoundation". From nixpkgs#515997 (the other half of
                # that PR, the clang_base_path rename, is superseded below by
                # nixpkgs#520445's simpler fix).
                ./patches/qtwebengine-lflags-remove-strip-darwin-isysroot.patch
              ];
            postPatch =
              old.postPatch
              + final.lib.optionalString final.stdenv.hostPlatform.isDarwin ''
                substituteInPlace cmake/QtToolchainHelpers.cmake \
                  --replace-fail 'clang_base_path="''${QWELibClang_BASE_PATH}"' 'clang_base_path="${final.stdenv.cc}"'

                substituteInPlace cmake/QtConfigureHelpers.cmake \
                  --replace-fail 'message(STATUS "Checking for Metal Toolchain")' 'message(STATUS "Checking for Metal Toolchain")
                set(TEST_metal_toolchain TRUE PARENT_SCOPE)
                return()'
              '';
            cmakeFlags =
              (final.lib.filter (
                flag: !(final.lib.hasPrefix "-DCMAKE_OSX_DEPLOYMENT_TARGET=" flag)
              ) old.cmakeFlags)
              ++ final.lib.optionals final.stdenv.hostPlatform.isDarwin [
                "-DCMAKE_OSX_DEPLOYMENT_TARGET=12.0"
                "-DCMAKE_CXX_COMPILER=${final.lib.getExe' final.stdenv.cc "clang++"}"
              ];
          });
        }
      );
    })
  ];

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
  homebrew.enableZshIntegration = true;
  homebrew.enableBashIntegration = true;
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
    "betterdisplay"
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
    "qlmarkdown"
    "quicklook-video"
    "raspberry-pi-imager"
    "raycast"
    "rocket"
    "setapp"
    "slack"
    "surfshark"
    "syntax-highlight" # provides QuickLook extension for highlighting code files
    "tailscale-app"
    "telegram"
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
    "iMovie" = 408981434;
  };

  # Used for backwards compatibility, please read the changelog before changing.
  # $ darwin-rebuild changelog
  system.stateVersion = 6;

  environment.systemPackages =
    (with pkgs; [
      aerospace
      # alacritty-graphics
      alacritty
      bun
      ccache
      ffmpeg
      firefox
      ghostty-bin
      google-chrome
      iina
      iterm2
      jellyfin-desktop
      keka
      melonds
      moreutils
      mosquitto
      nix-output-monitor
      openscad-unstable
      qbittorrent
      rclone
      spotdl
      spotify
      utm
      uv
      wireshark
      # whatsapp-for-mac
    ])
    ++ (with inputs.llm-agents.packages.${pkgs.stdenv.hostPlatform.system}; [
      # claude-code
      copilot-cli
    ])
    ++ [
      inputs.colmena.packages.${pkgs.stdenv.hostPlatform.system}.colmena
    ];

  fonts.packages = [
    pkgs.nerd-fonts.meslo-lg
  ];

  # set environment variables
  environment.variables = {
    LANG = "en_US.UTF-8";
    LC_ALL = "en_US.UTF-8";
  };

}
