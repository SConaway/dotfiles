{ config, pkgs, ... }:

{
  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  # List packages installed in system profile.
  environment.systemPackages = with pkgs; [
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
