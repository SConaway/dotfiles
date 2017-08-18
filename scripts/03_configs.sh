restore_settings() {
  ruby "${HOME}/Library/Mobile Documents/com~apple~CloudDocs/darkhouse/_run_house/quick_restore.rb"
}

set_default_apps() {
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

  for ext in {css,js,json,md,php,pug,py,rb,sh,txt,yaml,yml}; do duti -s com.github.atom "${ext}" all; done # code
}




configure_zsh() { # make zsh default shell
  sudo -S sh -c 'echo "/usr/local/bin/zsh" >> /etc/shells' <<< "${sudo_password}" 2> /dev/null
  sudo -S chsh -s '/usr/local/bin/zsh' "${USER}" <<< "${sudo_password}" 2> /dev/null
}

install_atom_packages() {
  # packages
  apm install highlight-line language-haskell language-pug language-swift linter linter-eslint linter-jsonlint linter-rubocop linter-shellcheck linter-write-good relative-numbers vim-mode-plus vim-mode-plus-keymaps-for-surround

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
