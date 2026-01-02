{
  config,
  pkgs,
  inputs,
  ...
}:

{
  programs.neovim = {
    enable = true;
    defaultEditor = true;
    viAlias = false;
    vimAlias = false;
  };

  # Link the remote flake input to the config directory
  # This symlinks ~/.config/nvim to the store path of the input
  # xdg.configFile."nvim".source = inputs.my-nvim-config;
}
