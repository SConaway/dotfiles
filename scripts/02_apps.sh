#! /usr/bin/env bash
# shellcheck disable=SC1090,SC2034,SC2154,SC2155
install_brew_stuff() {
  renew_sudo

  brew bundle --file ../Brewfile

}
