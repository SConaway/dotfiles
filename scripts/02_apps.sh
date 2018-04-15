#! /bin/bash
install_brew_apps() {
  renew_sudo
  brew tap alehouse/homebrew-unofficial
  renew_sudo
  if [ $on_ci = true ]; then
    echo
  else
    brew install boost
  fi

  brew install aria2 avrdude cask ccache cmake
  renew_sudo
  brew install cowsay cpulimit curl dockutil duti ffmpeg
  renew_sudo
  brew install fontconfig ghi git git-ftp git-lfs gradle handbrake hr
  renew_sudo
  brew install imagemagick lame livestreamer m-cli mas
  renew_sudo
  brew install mediainfo mp4v2 mpv openssl p7zip python python3 qemu ripgrep
  renew_sudo
  brew install rmlint shellcheck trash tree unrar wget youtube-dl z

  renew_sudo

  # install zsh_plugins
  brew install zsh-autosuggestions zsh-completions zsh-history-substring-search zsh-syntax-highlighting
  renew_sudo
  # install apps from other taps
  brew install laurent22/massren/massren
  renew_sudo

  # install and configure tor
  brew install tor torsocks
  renew_sudo
  cp "$(brew --prefix)/etc/tor/torrc.sample" "$(brew --prefix)/etc/tor/torrc"
  echo 'ExitNodes {us}' >> "$(brew --prefix)/etc/tor/torrc"

  echo "Brew Apps Installed"
}

install_cask_apps_part_1() {
  renew_sudo # to make the Caskroom on first install
  if [ $on_ci = true ]; then
    echo "Skip Amazon Music"
  else
    brew cask install amazon-music
  fi

  brew tap caskroom/versions
  brew tap caskroom/drivers
  brew tap alehouse/homebrew-unofficial
  renew_sudo
  brew cask install java
  renew_sudo
  brew cask install applepi-baker arduino atom
  renew_sudo
  brew cask install bartender bettertouchtool blockblock
  renew_sudo
  brew cask install caffeine calibre cheatsheet coconutbattery
  renew_sudo
  brew cask install disk-inventory-x docker dropbox
  renew_sudo
  brew cask install eclipse-java etcher filezilla
  renew_sudo
  brew cask install flux free-download-manager firefox
  if [ $on_ci = true ]; then
    echo
  else
    brew cask install fritzing
  fi
  renew_sudo
  if [ $on_ci = true ]; then
    echo "Skip Garmin Express"
  else
    brew cask install garmin-express
  fi
  brew cask install gfxcardstatus gimp gitup google-chrome iterm2
  renew_sudo
  brew cask install keka kid3 knockknock lastpass
  renew_sudo
  brew cask install lockdown mediainfo minecraft namechanger # mounty
  renew_sudo
  brew cask install openemu-experimental openscad osxfuse
  renew_sudo
  brew cask install oversight &
  sleep 120
  killall "OversightXPC"
  killall "OverSight Helper"

  echo "Cask Apps Part 1 Installed"

}

install_cask_apps_part_2() {
  renew_sudo # to make the Caskroom on first install
  if [ $on_ci = true ]; then
    echo "Skip Amazon Music"
  else
    brew cask install amazon-music
  fi
  brew tap caskroom/versions
  brew tap caskroom/drivers
  brew tap alehouse/homebrew-unofficial
  renew_sudo
  brew cask install java
  renew_sudo
  brew cask install processing ransomwhere razer-synapse real-vnc rocket
  renew_sudo
  brew cask install silicon-labs-vcp-driver 
  renew_sudo
  if [ $on_ci = true ]; then
    echo "Skip Sketchup"
  else
    brew cask install sketchup
  fi
  brew cask install taskexplorer spectacle steam
  renew_sudo
  brew cask install torbrowser transmission ultimaker-cura virtualbox vlc
  renew_sudo
  if [ $on_ci = true ]; then
    echo
  else
    brew cask install caskroom/drivers/wch-ch34x-usb-serial-driver
  fi
  renew_sudo
  brew cask install wd-firmware-updater whatsyoursign yacreader
  renew_sudo
  brew cask install xquartz

  # prefpanes, qlplugins, colorpickers
  brew cask install epubquicklook qlcolorcode qlimagesize qlmarkdown qlplayground qlstephen quicklook-json quicklookase
  renew_sudo
  # fonts
  brew tap caskroom/fonts
  # multiple
  ! brew cask install font-alegreya font-alegreya-sans font-alegreya-sc # font-alegreya-sc seems to error
  renew_sudo
  brew cask install font-fira-mono font-fira-sans
  renew_sudo
  brew cask install font-input
  renew_sudo
  renew_sudo
  brew cask install font-merriweather font-merriweather-sans
  renew_sudo
  brew cask install font-pt-mono font-pt-sans font-pt-serif
  renew_sudo
  brew cask install font-source-code-pro font-source-sans-pro font-source-serif-pro
  renew_sudo
  # sans
  brew cask install font-aileron font-bebas-neue font-exo2 font-montserrat font-lato font-open-sans font-open-sans-condensed font-signika
  renew_sudo
  # serif
  brew cask install font-abril-fatface font-butler font-gentium-book-basic font-playfair-display font-playfair-display-sc # font-playfair-display seems to error
  renew_sudo
  # slab
  brew cask install font-bitter font-kreon
  echo "Cask Apps Part 2 Installed"
  echo "All Cask Apps Installed"
  renew_sudo

  # games
  #brew cask install gridwars noiz2sa rootage torustrooper
}

install_tinyscripts() {
  renew_sudo
  brew tap vitorgalvao/tinyscripts
  gem install --no-document watir
  brew install annotmd cask-repair crafts fastmerge gfv gifmaker human-media-time labelcolor podbook prfixmaster progressbar ringtonemaker seren ubuntu-usb
  echo "Tiny Scripts Installed"
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
  echo "Oh My ZSH Installed"
}
