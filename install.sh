#! /bin/bash
run_install_dotfiles() {
  caffeinate & # prevent computer from going to sleep


  clear
  if [[ $# -eq 0 ]] ; then

    curl --progress-bar --location 'https://github.com/sconaway/dotfiles/archive/master.zip' | ditto -xk - '/tmp' # download and extract script

    # source all shell scripts
    for shell_script in '/tmp/dotfiles-master/scripts/'*.sh; do
      source "${shell_script}"
    done

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

    # source all shell scripts
    for shell_script in '/tmp/dotfiles-master/scripts/'*.sh; do
      source "${shell_script}"
    done

    initial_setup
    brew upgrade

    install_python
    install_ruby
    install_node
    install_zsh

    case $1 in
     '0')
        echo "CI Part 0"
        ;;
      '1')
        echo "CI Part 1"
        ;;

      '2')
        echo "CI Part 2"
        ;;

      '3')
        echo "CI Part 3"
        ;;

      '4')
        echo "CI Part 4"
        ;;

      '5')
        echo "CI Part 5"
        ;;

      '6')
        echo "CI Part 6"
        ;;

      *)
        echo "CI Part not recognized"
        ;;
        esac


  fi


}

# run and log errors to file (but still show them when they happen)
readonly error_log="${HOME}/Desktop/install_errors.log"
run_install_dotfiles "$1" 2> >(tee "${error_log}")
