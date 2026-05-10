{ config, pkgs, ... }:

{
  programs.zsh = {
    enable = true;
    enableCompletion = true;
    # autosuggestion.enable = true; # often conflicts with other plugins, enable if desired
    syntaxHighlighting.enable = true;

    # completionInit = ''
    #   autoload -U compinit
    #   echo completionInit
    #   if [[ -n ''${ZDOTDIR:-$HOME}/.zcompdump(#qN.mh+24) ]]; then
    #     compinit -u
    #   else
    #     compinit -uC
    #   fi
    # '';

    initContent = ''
      # echo "initContent start"
      # zmodload zsh/zprof
      # Powerlevel10k
      export ZSH=${pkgs.oh-my-zsh}/share/oh-my-zsh
      # echo "export ZSH"
      # export POWERLEVEL9K_DISABLE_GITSTATUSD=true
      # export POWERLEVEL9K_DISABLE_GITSTATUS=true
      source ${pkgs.zsh-powerlevel10k}/share/zsh-powerlevel10k/powerlevel10k.zsh-theme
      source ${../../../shell/p10k.zsh}
      # echo "p10k done"

      # Source the legacy zshrc content (minus the atuin init which HM handles)
      # echo "load zshrc"
      ${builtins.readFile ../../../shell/zshrc}
      # zprof
      # echo "initContent done"
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
