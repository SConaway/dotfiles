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
  if [ "$on_ci" -n true ]; then
    brew install --force-bottle ruby
  else
    brew install ruby
  fi
  if [ "$on_ci" -n true ]; then
    echo "Skip gems"
  else
    # install some gems
    gem install --no-document bundler rubocop rubocop-cask maid travis video_transcoding
    gem install --no-document pygments.rb # needed for installing ghi with brew
  fi
  echo "Ruby Installed"
}

install_node() {
  if [ "$on_ci" -n true ]; then
    brew install --force-bottle node yarn
  else
    brew install node yarn
  fi
  yarn config set prefix "$(brew --prefix)"
  yarn config set ignore-engines
  # install some packages
  yarn global add eslint eslint-plugin-immutable eslint-plugin-shopify jsonlint nightmare pageres-cli prettier
  echo "Node Installed"
}

install_zsh() {
  renew_sudo
  if [ "$on_ci" -n true ]; then
    brew install --force-bottle zsh --without-etcdir
  else
    brew install zsh --without-etcdir
  fi
  echo "ZSH Installed"
}
