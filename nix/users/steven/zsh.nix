{ config, pkgs, ... }:

{
  programs.zsh = {
    enable = true;

    initContent = ''
      # zmodload zsh/zprof
      # Powerlevel10k
      export ZSH=${pkgs.oh-my-zsh}/share/oh-my-zsh
      source ${pkgs.zsh-powerlevel10k}/share/zsh-powerlevel10k/powerlevel10k.zsh-theme
      source ${../../../shell/p10k.zsh}

      # Source zshrc (minus the atuin init which HM handles)
      ${builtins.readFile ../../../shell/zshrc}

      eval "$(zsh-patina activate)"

      # zprof
    '';
  };

  # Atuin managed by Home Manager
  programs.atuin = {
    enable = true;
    enableZshIntegration = true;
    # We link the config file directly below, so no need to map settings here individually
  };

  # Link the atuin config file directly
  xdg.configFile."atuin/config.toml".source = ../../modules/files/config/atuin/config.toml;
}
