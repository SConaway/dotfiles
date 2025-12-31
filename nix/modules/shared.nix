{ config, pkgs, ... }:

{
  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  # List packages installed in system profile.
  environment.systemPackages = with pkgs;
    [
      git
      zsh
      rustc
      python3
      nodejs-slim
      curl
      wget
      btop
      iftop
      lazygit
      rsync
      unzip
      neovim
      gh
      ripgrep
      fzf
      bat
      tmux
      oh-my-zsh
      atuin
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
    automatic = true;
    options = "--delete-older-than 7d";
  };
  
  # Nix Settings (Shared)
  nix.settings = {
    experimental-features = [ "nix-command" "flakes" ];
  };
}
