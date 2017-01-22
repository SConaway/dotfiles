restore_settings() {
  ruby "${HOME}/Library/Mobile Documents/com~apple~CloudDocs/darkhouse/_run_house/quick_restore.rb"
}

set_default_apps() {
  # fix duplicates in `open with`
  /System/Library/Frameworks/CoreServices.framework/Frameworks/LaunchServices.framework/Support/lsregister -kill -r -domain local -domain system -domain user
  killall Finder

  # open the mpv app bundle, so the system actually sees it (since it's not in a standard location)
  readonly local mpv_location="$(readlink "$(brew --prefix)/bin/mpv" | sed "s:^\.\.:$(brew --prefix):;s:bin/mpv$:mpv.app:")"
  if [[ -n "${mpv_location}" ]]; then
    readonly local mpv_process="$(pgrep -f 'mpv.app')"
    if [[ -z "${mpv_process}" ]]; then
      open "${mpv_location}"
      sleep 2
      killall mpv
    fi
  fi

  # general extensions
  for ext in {aac,avi,f4v,flac,m4a,m4b,mkv,mov,mp3,mp4,mpeg,mpg,wav,webm}; do duti -s io.mpv "${ext}" all; done # media
  for ext in {7z,bz2,gz,rar,tar,tgz,zip}; do duti -s com.aone.keka "${ext}" all; done # archives
  for ext in {cbr,cbz}; do duti -s com.richie.YACReader "${ext}" all; done # image archives
  for ext in {css,js,json,md,php,pug,py,rb,sh,txt}; do duti -s com.github.atom "${ext}" all; done # code

  # Affinity apps (use beta versions)
  for ext in {afdesign,eps}; do duti -s com.seriflabs.affinitydesigner.beta "${ext}" all; done
  duti -s com.seriflabs.affinityphoto.beta afphoto all
}

# set_keyboard_shortcuts() {
  # Custom keyboard shortcuts for apps
  # @ is ⌘; ~ is ⌥; $ is ⇧; ^ is ⌃
  # read more at https://web.archive.org/web/20140810142907/http://hints.macworld.com/article.php?story=20131123074223584

  # Global
  # defaults write -g NSUserKeyEquivalents '{}'

  # Tweetbot
  # defaults write com.tapbots.TweetbotMac NSUserKeyEquivalents '{
  #   "Open Links"="l";
  #   "Send to Pinboard"="$l";
  # }'
# }

install_verb_font() {
  ditto -xk "${HOME}/Library/Mobile Documents/com~apple~CloudDocs/verb_font/Verb_Desktop_Web.zip" '/tmp'
  mv '/tmp/Verb_Desktop_Web/YDS Verb Complete/Verb'* "${HOME}/Library/Fonts"
}

configure_zsh() { # make zsh default shell
  sudo -S sh -c 'echo "/usr/local/bin/zsh" >> /etc/shells' <<< "${sudo_password}" 2> /dev/null
  sudo -S chsh -s '/usr/local/bin/zsh' "${USER}" <<< "${sudo_password}" 2> /dev/null
}

install_nvim_packages() {
  # download and configure vim-plug
  # there's a chance it won't be needed in the future (https://github.com/junegunn/vim-plug/issues/249)
  curl --silent --location 'https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim' --output "${HOME}/.config/nvim/autoload/plug.vim" --create-dirs
  nvim +PlugInstall +qall
}

fix_initial_nvim_health() {
  # save CheckHealth pre fixes so in future installs we can identify which are no longer needed
  nvim +CheckHealth +'w ~/Desktop/Neovim_CheckHealth_before_fixes.txt' +qall

  # fixes needed last time it was checked
  infocmp "${TERM}" | sed 's/kbs=^[hH]/kbs=\\177/' > "/tmp/${TERM}.ti"
  tic "/tmp/${TERM}.ti"

  nvim +CheckHealth +'w ~/Desktop/Neovim_CheckHealth_after_fixes.txt' +qall
}

install_atom_packages() {
  # packages
  apm install atom-beautify highlight-line language-haskell language-pug language-swift linter linter-eslint linter-jsonlint linter-rubocop linter-shellcheck linter-write-good relative-numbers vim-mode vim-surround

  # themes and syntaxes
  apm install peacock-syntax
}

configure_git() {
  git config --global user.name "${name}"
  git config --global user.email "${github_email}"
  git config --global github.user "${github_username}"
  git config --global credential.helper osxkeychain
  git config --global push.default simple
  git config --global rerere.enabled true
  git config --global rerere.autoupdate true
}

configure_pinboard_scripts() {
  pinboardlinkcheck --save-token --token "${pinboard_token}"
}

install_launchagents() {
  readonly local user_launchagents_dir="${HOME}/Library/LaunchAgents"
  readonly local global_launchdaemons_dir='/Library/LaunchDaemons/'
  mkdir -p "${user_launchagents_dir}"

  for plist_file in "${helper_files}/launchd_plists/user_plists"/*; do
    local plist_name=$(basename "${plist_file}")

    mv "${plist_file}" "${user_launchagents_dir}"
    launchctl load -w "${user_launchagents_dir}/${plist_name}"
  done

  for plist_file in "${helper_files}/launchd_plists/global_plists"/*; do
    local plist_name=$(basename "${plist_file}")

    sudo mv "${plist_file}" "${global_launchdaemons_dir}" <<< "${sudo_password}" 2> /dev/null
    sudo chown root "${global_launchdaemons_dir}/${plist_name}" <<< "${sudo_password}" 2> /dev/null
    sudo launchctl load -w "${global_launchdaemons_dir}/${plist_name}" <<< "${sudo_password}" 2> /dev/null
  done

  rmdir -p "${helper_files}/launchd_plists"/* 2> /dev/null
}

lower_startup_chime() {
  curl -fsSL 'https://raw.githubusercontent.com/vitorgalvao/lowchime/master/lowchime' --output '/tmp/lowchime'
  chmod +x '/tmp/lowchime'
  sudo -S /tmp/lowchime install <<< "${sudo_password}" 2> /dev/null
}
