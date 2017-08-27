#! /bin/bash
run_install_dotfiles() {
  caffeinate & # prevent computer from going to sleep


  clear
  if [[ $# -eq 0 ]] ; then
    on_ci=false

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
    install_oh_my_zsh

    set_brew_default_apps
    set_cask_default_apps
    configure_zsh
    install_atom_packages
    configure_git
    install_launchagents
    lower_startup_chime
    copy_dotfiles
    os_customize

    cleanup_brew
    cleanup_error_log
    move_manual_action_files
    killall caffeinate # computer can go back to sleep
    final_message
  else
    echo "Running on CI"
    on_ci=true

    # source all shell scripts
    for shell_script in '/tmp/dotfiles-master/scripts/'*.sh; do
      source "${shell_script}"
    done

    initial_setup
    brew update
    brew upgrade

    install_python
    install_ruby
    install_node
    install_zsh

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
        ;;

      '2')
        echo "CI Part 2"
        install_cask_apps_part_2
        ;;

      '3')
        echo "CI Part 3"
        install_tinyscripts
        ;;

      '4')
        echo "CI Part 4"
        lower_startup_chime
        os_customize
        ;;

      '5')
        echo "CI Part 5"
        cleanup_brew
        cleanup_error_log
        ;;

      '6')
        echo "CI Part 6"
        killall caffeinate # computer can go back to sleep
        final_message
        ;;

      *)
        echo "CI Part not recognized"
        exit 1
        ;;
        esac


  fi


}

# run and log errors to file (but still show them when they happen)
readonly error_log="${HOME}/Desktop/install_errors.log"
run_install_dotfiles "$1" 2> >(tee "${error_log}")
