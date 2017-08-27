#! /bin/bash
install_brew() {
  renew_sudo
  /usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)" < /dev/null
  brew analytics off

  echo "Brew Installed"
}

install_python() {
  brew install python python3
  echo "Python Installed"
}

install_ruby() {
  brew install ruby
  # install some gems
  gem install --no-document bundler rubocop rubocop-cask maid travis video_transcoding
  gem install --no-document pygments.rb # needed for installing ghi with brew
  echo "Ruby Installed"
}

install_node() {
  brew install node yarn
  yarn config set prefix "$(brew --prefix)"
  yarn config set ignore-engines
  # install some packages
  yarn global add eslint eslint-plugin-immutable eslint-plugin-shopify jsonlint nightmare pageres-cli prettier
  echo "Node Installed"
}

install_zsh() {
  renew_sudo
  brew install zsh --without-etcdir
  echo "ZSH Installed"
}
