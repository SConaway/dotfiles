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

  # Link other config files
  xdg.configFile."aerospace/aerospace.toml".source = ../../modules/files/config/aerospace/aerospace.toml;
  xdg.configFile."aerospace-swipe/config.json".source = ../../modules/files/config/aerospace-swipe/config.json;
  xdg.configFile."alacritty/alacritty.toml".source = ../../modules/files/config/alacritty/alacritty.toml;
}
