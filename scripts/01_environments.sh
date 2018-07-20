#! /usr/bin/env bash
# shellcheck disable=SC1090,SC2034,SC2154,SC2155
install_brew() {
  renew_sudo
  /usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)" < /dev/null
  brew analytics off
  git -C "$(brew --repo homebrew/core)" fetch --unshallow

  echo "Brew Installed"
}

install_python() {
  brew install python pip2 python3 pip3
  echo "Python Installed"
}

install_ruby() {
  if [[ -v CI ]]; then
    brew install --force-bottle ruby
  else
    brew install ruby
  fi
  if [[ -v CI ]]; then
    echo "Skip gems"
  else
    # install some gems
    gem install --no-document bundler pygments.rb rubocop rubocop-cask maid travis
  fi
  echo "Ruby and gems Installed"
}

install_node() {
  if [[ -v CI ]]; then
    brew install --force-bottle node yarn
  else
    brew install node yarn
  fi
  yarn config set prefix "$(brew --prefix)"
  yarn config set ignore-engines
  # install some packages
  yarn global add jsonlint nightmare pageres-cli
  echo "Node and Packages Installed"
}

install_zsh() {
  renew_sudo
  if [[ -v CI ]]; then
    brew install --force-bottle zsh
  else
    brew install zsh
  fi
  echo "ZSH Installed"
}
