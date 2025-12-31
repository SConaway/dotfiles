{ pkgs, lib, ... }:

let
  isDarwin = pkgs.stdenv.isDarwin;
  homeDir = if isDarwin then "/Users/steven" else "/home/steven";
in
{
  imports = [
    ./nvim.nix
    ./zsh.nix
  ];

  home.username = "steven";
  home.homeDirectory = homeDir;

  home.stateVersion = "24.05";

  programs.home-manager.enable = true;
}
