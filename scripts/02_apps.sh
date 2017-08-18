install_brew_apps() {
  renew_sudo
  brew install zsh --without-etcdir

  brew install aria2 avrdude cask ccache cmake cowsay cpulimit dockutil duti ffmpeg fontconfig ghi git git-ftp handbrake hr imagemagick lame livestreamer m-cli mas mediainfo mp4v2 python python3 qemu ripgrep rmlint shellcheck trash tree wget youtube-dl z
  renew_sudo

  # install zsh_plugins
  brew install zsh-autosuggestions zsh-completions zsh-history-substring-search zsh-syntax-highlighting
  renew_sudo
  # install apps from other taps
  brew install laurent22/massren/massren
  renew_sudo

  # install and configure tor
  brew install tor torsocks
  cp "$(brew --prefix)/etc/tor/torrc.sample" "$(brew --prefix)/etc/tor/torrc"
  echo 'ExitNodes {us}' >> "$(brew --prefix)/etc/tor/torrc"
}

install_cask_apps() {
  renew_sudo # to make the Caskroom on first install
  brew cask install alfred amazon-music android-file-transfer android-studio applepi-baker anka-run apple-events arduino atom bartender bettertouchtool blockblock calibre dolphin dropbox electron-api-demos fog gifloopcoder gitup google-chrome imageoptim imitone iterm2 keka oversight processing shotcut spectacle steam torbrowser transmission veertu-desktop whale whatsyoursign wwdc yacreader

  brew cask install pokerstars --language='PT'

  # install alternative versionss
  brew tap caskroom/versions
  brew cask install dash3 google-chrome-canary openemu-experimental screenflow5

  # drivers
  brew tap caskroom/drivers
  renew_sudo
  brew cask install xbox360-controller-driver

  # prefpanes, qlplugins, colorpickers
  brew cask install betterzipql epubquicklook qlcolorcode qlimagesize qlmarkdown qlplayground qlstephen quicklook-json quicklookase

  # fonts
  brew tap caskroom/fonts
  # multiple
  brew cask install font-alegreya font-alegreya-sans font-alegreya-sans-sc font-alegreya-sc
  brew cask install font-fira-mono font-fira-sans
  brew cask install font-input
  brew cask install font-merriweather font-merriweather-sans
  brew cask install font-pt-mono font-pt-sans font-pt-serif
  brew cask install font-source-code-pro font-source-sans-pro font-source-serif-pro
  # sans
  brew cask install font-aileron font-bebas-neue font-exo2 font-montserrat font-lato font-open-sans font-open-sans-condensed font-signika
  # serif
  brew cask install font-abril-fatface font-butler font-gentium-book-basic font-playfair-display font-playfair-display-sc
  # slab
  brew cask install font-bitter font-kreon
  # script
  brew cask install font-pecita

  # games
  #brew cask install gridwars noiz2sa rootage torustrooper
}

install_tinyscripts() {
  brew tap vitorgalvao/tinyscripts
  brew install annotmd cask-repair contagem-edp customise-terminal-notifier fastmerge gfv gifmaker human-media-time labelcolor lovecolor pedir-gas pinboardbackup pinboardlinkcheck pinboardwaybackmachine podbook prfixmaster progressbar ringtonemaker seren trello-purge-archives
}

install_mas_apps() {
  readonly local mas_apps=('apple_configurator_2=1037126344' 'hp_easy_scan=967004861' 'day_one=1055511498' 'xcode=497799835' 'cleanmydrive=523620159')

  mas signin "${mas_email}" "${mas_password}"

  for app in "${mas_apps[@]}"; do
    local app_id="${app#*=}"
    mas install "${app_id}"
  done
}
