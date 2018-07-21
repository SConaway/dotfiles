#! /usr/bin/env bash
# shellcheck disable=SC1090,SC2034,SC2154,SC2155
bold_echo() { # helper function for bold text
  echo "$(tput bold)${1}$(tput sgr0)"
}

renew_sudo() { # helper function for when the following command needs `sudo` active but shouldn't be called with it
  sudo --stdin --validate <<< "${sudo_password}" 2> /dev/null
}

initial_setup() {
  export PATH="/usr/local/bin:${PATH}"

  trap 'exit 0' SIGINT # exit cleanly if aborted with ⌃C

  # variables for helper files and directories
  readonly helper_files='./files' # /tmp/dotfiles-master/files'
  readonly command_files='./commands' # /tmp/dotfiles-master/commands'
  readonly command_files_dest='$HOME/bin'
  mkdir -p "$HOME/bin"
  readonly post_install_files="${HOME}/Desktop/post_install_files"
  readonly post_install_script="${HOME}/Desktop/post_install_script.sh"
}

ask_details() {
  # ask for the administrator password upfront, for commands that require `sudo`
  clear
  bold_echo 'Insert the "sudo" password now (will not be echoed).'
  until sudo -n true 2> /dev/null; do # if password is wrong, keep asking
    read -r -s -p 'Password: ' sudo_password
    echo
    sudo -S -v <<< "${sudo_password}" 2> /dev/null
  done

  clear
  bold_echo 'Your Mac App Store details to install apps:'
  read -r -p 'MAS email: ' mas_email
  read -r -s -p 'MAS password (will not be echoed): ' mas_password

  clear
  bold_echo 'Some details to be used when configuring git:'
  read -r -p 'First and last names: ' name
  read -r -p 'Github username: ' github_username
  read -r -p 'Github token (Create a token with the "repo" scope for CLI access from https://github.com/settings/tokens): ' github_token
  read -r -p 'Github email: ' github_email

  clear
  bold_echo 'Some contact information to be set in the lock screen:'
  read -r -p 'Email address: ' email
  read -r -p 'Telephone number: ' telephone
  sudo -S defaults write /Library/Preferences/com.apple.loginwindow LoginwindowText "Email: ${email}\\nTel: ${telephone}" <<< "${sudo_password}" 2> /dev/null

  clear
  bold_echo 'Where are the home dofiles you would like to copy Located'
  read -r -p 'Home Dotfiles ' home_dotfiles

  clear
  bold_echo 'Where are the root dofiles you would like to copy Located'
  read -r -p 'Root Dotfiles ' root_dotfiles

  clear

#  verify
}

sync_icloud() {
  bold_echo 'Press the download icons to download everything.'
  open "${HOME}/Library/Mobile Documents/com~apple~CloudDocs"
}

update_system() {
  softwareupdate --install --all
}
