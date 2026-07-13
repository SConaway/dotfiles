{
  config,
  pkgs,
  inputs,
  ...
}:

{
  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  # List packages installed in system profile.
  environment.systemPackages = with pkgs; [
    attic-client
    atuin
    bat
    btop
    curl
    eza
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
    zellij
    zsh
    inputs.zsh-patina.packages.${pkgs.stdenv.hostPlatform.system}.default
    inputs.colmena.packages.${pkgs.stdenv.hostPlatform.system}.colmena
  ];

  nix.settings.auto-optimise-store = true;

  # Nix Settings (Shared)
  nix.settings = {
    experimental-features = [
      "nix-command"
      "flakes"
    ];

    # Pull-through cache for source-built packages (colmena, zsh-patina, etc.)
    # served by id-attic over Tailscale.
    substituters = [ "http://id-attic:8080/homelab" ];
    trusted-public-keys = [ "homelab:yCQlAzmcPZfjWhjm/W2jlZZCxhFZGVQjAELYLhPbNCk=" ];
  };

}
