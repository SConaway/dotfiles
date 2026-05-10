{ config, pkgs, ... }:

{
  # List packages installed in system profile.
  environment.systemPackages = with pkgs; [
    cargo
    deadnix
    fd
    go
    lazygit
    neovim
    nixd
    nodejs
    python3
    python3Packages.pip
    ripgrep
    rustc
    statix
    tree-sitter
    # tree-sitter-grammars
  ];
}
