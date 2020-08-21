#! /usr/bin/env bash
# shellcheck disable=SC1090,SC2034,SC2154,SC2155
install_brew() {

  renew_sudo
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install.sh)"

  echo "Brew Installed"
}

install_python() {

  brew install python@3
  echo "Python Installed"
}

install_ruby() {

  brew install ruby
  # install some gems
  gem install --no-document bundler maid travis

  echo "Ruby and gems Installed"
}

install_node() {

  brew install node yarn

  echo "Node Installed"
}

install_zsh() {
  renew_sudo

  brew install zsh

  echo "ZSH Installed"
}
