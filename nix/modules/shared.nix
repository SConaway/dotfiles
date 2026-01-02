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
    fzf
    gh
    git
    glow # terminal .md renderer
    go
    iftop
    lazygit
    massren
    nixfmt-tree
    nodejs
    oh-my-zsh
    python3
    python313Packages.pygments
    ripgrep
    rsync
    tmux
    unzip
    wget
    zsh
  ];

  # not sure if this is doing anything
  nix.settings.warn-dirty = false;
  # try this?
  nix.settings.auto-optimise-store = true;

  # Nix Settings (Shared)
  nix.settings = {
    experimental-features = [
      "nix-command"
      "flakes"
    ];
  };

}
