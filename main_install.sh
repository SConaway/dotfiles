#! /bin/bash
caffeinate & # prevent computer from going to sleep

  clear
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
        configure_lastpass
        configure_whatsyoursign
        install_launchagents
        copy_commands
        link_airport
        lower_startup_chime
        copy_dotfiles
        configure_dock
        os_customize

        cleanup_brew
        cleanup_error_log
        move_manual_action_files
        killall caffeinate # computer can go back to sleep
        final_message
