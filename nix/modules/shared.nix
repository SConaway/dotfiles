{ config, pkgs, ... }:

{
  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  # List packages installed in system profile.
  environment.systemPackages = with pkgs;
    [
      atuin
      bat
      btop
      curl
      fzf
      gh
      git
      iftop
      lazygit
      massren
      neovim
      nodejs-slim
      oh-my-zsh
      python3
      ripgrep
      rsync
      rustc
      tmux
      unzip
      wget
      zsh
  ];

  # Shell Configuration
  programs.zsh = {
    enable = true;
    # interactiveShellInit runs before promptInit, so we must set ZSH here
    interactiveShellInit = ''
      export ZSH=${pkgs.oh-my-zsh}/share/oh-my-zsh
      source ${pkgs.zsh-powerlevel10k}/share/zsh-powerlevel10k/powerlevel10k.zsh-theme
    '' + builtins.readFile ./files/zshrc;
    promptInit = "";
  };
  
  # Nix Garbage Collection (Shared)
  nix.gc = {
    automatic = false; # TODO: disable on mac
    options = "--delete-older-than 7d";
  };
  
  # Nix Settings (Shared)
  nix.settings = {
    experimental-features = [ "nix-command" "flakes" ];
  };
}
