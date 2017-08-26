#! /bin/bash
run_install_dotfiles() {
  caffeinate & # prevent computer from going to sleep
  curl --progress-bar --location 'https://github.com/sconaway/dotfiles/archive/master.zip' | ditto -xk - '/tmp' # download and extract script

  # source all shell scripts
  for shell_script in '/tmp/dotfiles-master/scripts/'*.sh; do
    source "${shell_script}"
  done

  clear
  if [[ $# -eq 0 ]] ; then
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

    cleanup_error_log
    move_manual_action_files
    killall caffeinate # computer can go back to sleep
    final_message
    cleanup_brew
  else
    echo "Running on CI"
    initial_setup
    brew update
    brew upgrade

    install_python
    install_ruby
    install_node
    install_zsh

  fi


}

# run and log errors to file (but still show them when they happen)
readonly error_log="${HOME}/Desktop/install_errors.log"
run_install_dotfiles 2> >(tee "${error_log}")
