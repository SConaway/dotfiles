#! /usr/bin/env bash
# shellcheck disable=SC1090,SC2034,SC2154,SC2155
install_brew_apps() {
  renew_sudo
  brew tap alehouse/homebrew-unofficial
  renew_sudo

  readonly local brew_apps=('aria2' 'avrdude' 'boost' 'cask' 'cmake' 'cowsay' 'curl' 'dockutil' 'duti' 'git' 'git-ftp' 'git-lfs' 'gradle' 'handbrake' 'hr' 'm-cli' 'mas' 'mediainfo' 'openssl' 'p7zip' 'python' 'python3' 'qemu' 'ripgrep' 'rmlint' 'shellcheck' 'sshrc' 'trash' 'tree' 'unrar' 'wget' 'youtube-dl' 'z' 'zsh-autosuggestions' 'zsh-completionsa' 'zsh-history-substring-search' 'zsh-syntax-highlighting')

  #mas signin "${mas_email}" "${mas_password}"
  renew_sudo

  for app in "${brew_apps[@]}"; do
    echo "Installing $app"
    brew install "${app}"
    renew_sudo
  done

  echo "Brew Apps Installed"
}

install_cask_apps_part_1() {
  renew_sudo # to make the Caskroom on first install
  if [[ -v CI ]]; then
    echo "Skip Amazon Music"
  else
    brew cask install amazon-music
  fi

  brew tap caskroom/versions
  brew tap caskroom/drivers
  brew tap alehouse/homebrew-unofficial
  brew tap caskroom/fonts

  renew_sudo


  readonly local cask_apps_1=('java' 'arduino' 'atom' 'caffeine' 'cheatsheet' 'coconutbattery' 'disk-inventory-x' 'docker' 'dropbox' 'eclipse-java' 'etcher' 'filezilla' 'flux' 'free-download-manager' 'firefox' 'fritzing' 'garmin-express' 'gfxcardstatus' 'gimp' 'gitup' 'google-chrome' 'iterm2' 'keka' 'kid3' 'knockknock' 'lastpass' 'lockdown' 'mediainfo' 'meld' 'minecraft' 'namechanger' 'openscad' 'osxfuse')

  for app in "${cask_apps_1[@]}"; do
    echo "Installing $app"
    brew cask install "${app}"
    renew_sudo
  done

  brew cask install oversight &
  sleep 120
  killall "OversightXPC"
  killall "OverSight Helper"

  echo "Cask Apps Part 1 Installed"

}

install_cask_apps_part_2() {
  renew_sudo # to make the Caskroom on first install
  if [[ -v CI ]]; then
    echo "Skip Amazon Music"
  else
    brew cask install amazon-music
  fi
  brew tap caskroom/versions
  brew tap caskroom/drivers
  brew tap alehouse/homebrew-unofficial
  brew tap caskroom/fonts


  renew_sudo


  readonly local cask_apps_2=('java' 'razer-synapse' 'real-vnc' 'rocket' 'silicon-labs-vcp-driver' 'sketchup' 'steam' 'taskexplorer' 'torbrowser' 'transmission' 'ultimaker-cura' 'virtualbox' 'vlc' 'caskroom/drivers/wch-ch34x-usb-serial-driver' 'wd-firmware-updater' 'whatsyoursign' 'vnc-viewer' 'vnc-server' 'xquartz' 'epubquicklook' 'qlcolorcode' 'qlimagesize' 'qlmarkdown' 'qlstephen' 'font-alegreya' 'font-alegreya-sans' 'font-fira-mono' 'font-fira-sans' 'font-input' 'font-merriweather' 'font-merriweather-sans' 'font-pt-mono' 'font-pt-sans' 'font-pt-serif' 'font-source-code-pro' 'font-source-sans-pro' 'font-source-serif-pro' 'font-aileron' 'font-bebas-neue' 'font-exo2' 'font-montserrat' 'font-lato' 'font-open-sans' 'font-open-sans-condensed' 'font-signika' 'font-abril-fatface' 'font-butler' 'font-gentium-book-basic' 'font-playfair-display' 'font-playfair-display-sc' 'font-bitter' 'font-kreon')

  for app in "${cask_apps_1[@]}"; do
    echo "Installing $app"
    brew cask install "${app}"
    renew_sudo
  done


}

install_mas_apps() {
  readonly local mas_apps=('apple_configurator_2=1037126344' 'hp_easy_scan=967004861' 'day_one=1055511498' 'cleanmydrive=523620159' 'xcode=497799835')

  #mas signin "${mas_email}" "${mas_password}"
  renew_sudo

  for app in "${mas_apps[@]}"; do
    local app_id="${app#*=}"
    renew_sudo
    mas install "${app_id}"
    renew_sudo
  done

  echo "Mac App Store Apps Installed"
}

install_oh_my_zsh() {
  renew_sudo
  sh -c "$(curl -fsSL https://raw.github.com/robbyrussell/oh-my-zsh/master/tools/install.sh)"
  git clone https://github.com/bhilburn/powerlevel9k.git ~/.oh-my-zsh/custom/themes/powerlevel9k
  echo "Oh My ZSH Installed"
}
