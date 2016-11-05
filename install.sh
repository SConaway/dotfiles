run_install_dotfiles() {
  curl --progress-bar --location 'https://github.com/vitorgalvao/dotfiles/archive/master.zip' | ditto -xk - '/tmp'

  # source all shell scripts
  for shell_script in '/tmp/dotfiles-master/scripts/'*.sh; do
    source "${shell_script}"
  done

  clear

  initial_setup
  ask_details
  update_system

  install_brew
  install_python
  install_ruby
  install_node

  install_brew_apps
  install_cask_apps
  install_tinyscripts
  install_mas_apps

  restore_settings
  set_default_apps
  # set_keyboard_shortcuts
  install_verb_font
  configure_zsh
  install_nvim_packages
  install_atom_packages
  configure_git
  install_launchagents
  lower_startup_chime
  alfred_allow_dropbox

  cleanup_brew
  move_manual_action_files
  killall caffeinate # computer can go back to sleep
  final_message
}

# run and log errors to file (but still show them when they happen)
readonly error_log="${HOME}/Desktop/install_errors.log"
run_install_dotfiles 2> >(tee "${error_log}")
