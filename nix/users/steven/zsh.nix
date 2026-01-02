{ config, pkgs, ... }:

{
  programs.zsh = {
    enable = true;
    enableCompletion = true;
    # autosuggestion.enable = true; # often conflicts with other plugins, enable if desired
    syntaxHighlighting.enable = true;

    initContent = ''
      # Powerlevel10k
      source ${../../modules/files/p10k.zsh}

      # Source the legacy zshrc content (minus the atuin init which HM handles)
      ${builtins.readFile ../../modules/files/zshrc}
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
