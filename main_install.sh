#! /usr/bin/env bash
# shellcheck disable=SC1090,SC2034,SC2154,SC2155
caffeinate & # prevent computer from going to sleep

clear
echo "$on_ci"
if [[ $# -eq 1 ]] ; then
#if [[ $on_ci -eq "yes" ]]; then
  for shell_script in '/tmp/dotfiles-master/scripts/'*.sh; do
    source "${shell_script}"
  done
  echo "Running on CI"
  on_ci=true

  initial_setup
  #
  install_python
  install_ruby
  install_node
  install_zsh
  #
  case $1 in
    '0')
    echo "CI Part 0"
    install_brew_apps
    ;;
    '1')
    echo "CI Part 1"
    brew install duti
    install_cask_apps_part_1
    set_cask_default_apps
    install_atom_packages
    ;;

    '2')
    echo "CI Part 2"
    install_cask_apps_part_2
    ;;

    '3')
    echo "CI Part 3"
    copy_commands
    link_airport
    lower_startup_chime
    os_customize
    configure_dock
    cleanup_brew
    cleanup_error_log
    killall caffeinate # computer can go back to sleep
    final_message
    ;;

    *)
    echo "CI Part not recognized"
    exit 1
    ;;
  esac

else

  for shell_script in './scripts/'*.sh; do
  #for shell_script in '/tmp/dotfiles-master/scripts/'*.sh; do
    source "${shell_script}"
  done
  on_ci=false

  initial_setup
  ask_details
  sync_icloud
  update_system
  #
  install_brew
  install_python
  install_ruby
  install_node
  install_zsh
  #
  install_brew_apps
  install_cask_apps_part_1
  install_cask_apps_part_2
  echo "Cask Apps Part 2 Installed"
  install_mas_apps
  install_oh_my_zsh
  #
  #set_brew_default_apps
  set_cask_default_apps
  configure_zsh
  install_atom_packages
  configure_git
  configure_lastpass
  configure_whatsyoursign
  # install_launchagents
  copy_commands
  link_airport
  lower_startup_chime
  #copy_dotfiles
  configure_dock
  os_customize
  #
  cleanup_brew
  cleanup_error_log
  move_manual_action_files
  killall caffeinate # computer can go back to sleep
  final_message
fi
