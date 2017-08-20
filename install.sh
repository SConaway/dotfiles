run_install_dotfiles() {
  caffeinate & # prevent computer from going to sleep
  curl --progress-bar --location 'https://github.com/sconaway/dotfiles/archive/master.zip' | ditto -xk - '/tmp' # download and extract script

  # source all shell scripts
  for shell_script in '/tmp/dotfiles-master/scripts/'*.sh; do
    source "${shell_script}"
  done

  clear


  initial_setup
  if ${CI:-}; then
    echo "Skip Setup and Brew"
    brew update
    brew upgrade
  else
    ask_details
    sync_icloud
    update_system

    install_brew
  fi

  install_python
  install_ruby
  install_node
  install_zsh

  if ${CI:-}; then
    if ${CI_PART_0:-}; then
      echo "CI Part 0"
      install_brew_apps
      set_brew_default_apps
    fi
    if ${CI_PART_1:-}; then
      echo "CI Part 1"
      install_cask_apps
      install_atom_packages
      set_cask_default_apps
    fi
    if ${CI_PART_2:-}; then
      echo "CI Part 2"
      install_tinyscripts
    fi
  else
    install_brew_apps
    install_cask_apps
    install_tinyscripts
  fi

  if ${CI:-}; then
    if ${CI_PART_3:-}; then
      echo "CI Part 3"
      install_mas_apps
    fi
  else
    install_mas_apps
    copy_apps
  fi
  if ${CI:-}; then
    if ${CI_PART_4:-}; then
      echo "CI Part 4"
      os_customize

    fi
  else
    install_oh_my_zsh
  fi

  if ${CI:-}; then
    if ${CI_PART_5:-}; then
      echo "CI Part 5"
      shellcheck install.sh
    fi
    if ${CI_PART_6:-}; then
      echo "CI Part 6"
    fi
  else
    restore_settings
    set_brew_default_apps
    set_cask_default_apps
    configure_zsh
    install_atom_packages
    configure_git
    install_launchagents
    lower_startup_chime
    os_customize
  fi


  cleanup_brew
  cleanup_error_log
  move_manual_action_files
  killall caffeinate # computer can go back to sleep
  if ${CI:-}; then
    echo "Done!"
  else
    final_message
  fi
}

# run and log errors to file (but still show them when they happen)
readonly error_log="${HOME}/Desktop/install_errors.log"
run_install_dotfiles 2> >(tee "${error_log}")
