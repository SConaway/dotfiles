{ config, pkgs, inputs, ... }:

{
  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  # List packages installed in system profile.
  environment.systemPackages = with pkgs; [
    agenix-cli
    atuin
    bat
    btop
    curl
    fd
    file
    fx
    fzf
    gh
    git
    glow # terminal .md renderer
    go
    iftop
    lazygit
    massren
    ncdu
    nixfmt
    nixfmt-tree
    nodejs
    oh-my-zsh
    python3
    python313Packages.pip
    python313Packages.pygments
    ripgrep
    rsync
    tmux
    tree
    unzip
    watch
    wget
    yarn
    zsh
    inputs.colmena.packages.${pkgs.stdenv.hostPlatform.system}.colmena
  ];

  nix.settings.auto-optimise-store = true;

  # Nix Settings (Shared)
  nix.settings = {
    experimental-features = [
      "nix-command"
      "flakes"
    ];
  };

}
