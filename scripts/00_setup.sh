#! /usr/bin/env bash
# shellcheck disable=SC1090,SC2034,SC2154,SC2155
bold_echo() { # helper function for bold text
  echo "$(tput bold)${1}$(tput sgr0)"
}

renew_sudo() { # helper function for when the following command needs `sudo` active but shouldn't be called with it
  sudo --stdin --validate <<<"${sudo_password}" 2>/dev/null
}

initial_setup() {
  export PATH="/usr/local/bin:${PATH}"

  trap 'exit 0' SIGINT # exit cleanly if aborted with ⌃C

}

ask_details() {
  # ask for the administrator password upfront, for commands that require `sudo`
  clear
  bold_echo 'Insert the "sudo" password now (will not be echoed).'
  until sudo -n true 2>/dev/null; do # if password is wrong, keep asking
    read -r -s -p 'Password: ' sudo_password
    echo
    sudo -S -v <<<"${sudo_password}" 2>/dev/null
  done

  clear

}

sync_icloud() {
  bold_echo 'Press the download icons to download everything.'
  open "${HOME}/Library/Mobile Documents/com~apple~CloudDocs"
}

update_system() {
  softwareupdate --install --all
}
