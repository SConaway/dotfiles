#! /bin/bash
run_install_dotfiles() {
  caffeinate & # prevent computer from going to sleep
  #curl --progress-bar --location 'https://github.com/sconaway/dotfiles/archive/master.zip' | ditto -xk - '/tmp' # download and extract script

  # source all shell scripts
  #for shell_script in '/tmp/dotfiles-master/scripts/'*.sh; do
  for shell_script in ~/Downloads/dotfiles-master/scripts/*.sh; do
    source "${shell_script}"
  done

  clear


  initial_setup
  ask_details
  sync_icloud
  update_system

  install_brew
  install_python
  install_ruby
  install_node
  install_zsh

  install_brew_apps
  install_cask_apps_part_1
  install_cask_apps_part_2
  install_tinyscripts
  install_mas_apps

  copy_apps
  copy_dotfiles
  install_oh_my_zsh
  restore_settings
  set_brew_default_apps
  set_cask_default_apps
  configure_zsh
  install_atom_packages
  configure_git
  install_launchagents
  lower_startup_chime
  os_customize


  cleanup_brew
  cleanup_error_log
  move_manual_action_files
  killall caffeinate # computer can go back to sleep
  final_message
}

# run and log errors to file (but still show them when they happen)
readonly error_log="${HOME}/Desktop/install_errors.log"
run_install_dotfiles 2> >(tee "${error_log}")
