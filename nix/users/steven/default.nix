{ pkgs, lib, ... }:

let
  isDarwin = pkgs.stdenv.hostPlatform.isDarwin;
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
  xdg.configFile = lib.mkIf isDarwin {
    "aerospace/aerospace.toml".source =
      ../../modules/files/config/aerospace/aerospace.toml;
    "aerospace-swipe/config.json".source =
      ../../modules/files/config/aerospace-swipe/config.json;
    "alacritty/alacritty.toml".source =
      ../../modules/files/config/alacritty/alacritty.toml;
  };
}
