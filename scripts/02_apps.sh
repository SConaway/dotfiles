#! /usr/bin/env bash
# shellcheck disable=SC1090,SC2034,SC2154,SC2155
install_brew_stuff() {
  renew_sudo

  sudo chown -R $(whoami) /usr/local/include /usr/local/lib /usr/local/lib/pkgconfig

  brew bundle

}
