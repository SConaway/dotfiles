#! /usr/bin/env bash
# shellcheck disable=SC1090,SC2034,SC2154,SC2155
info() {
  echo "$(tput setaf 2)•$(tput sgr0) ${1}"
}

request() { # output a message and open an app
  local message="${1}"
  local app="${2}"
  shift 2

  echo "$(tput setaf 5)•$(tput sgr0) ${message}"
  open -Wa "${app}" --args "$@" # don't continue until app closes
}

request_preferences() { # 'request' for System Preferences
  request "${1}" 'System Preferences'
}

request_chrome_extension() { # 'request' for Google Chrome extensions
  local chrome_or_canary="${1}"
  local extension_short_name="${2}"
  local extension_code="${3}"

  request "Install '${extension_short_name}' extension." "${chrome_or_canary}" --no-first-run "https://chrome.google.com/webstore/detail/${extension_short_name}/${extension_code}"
}

preferences_pane() { # open 'System Preferences' is specified pane
  osascript -e "tell application \"System Preferences\"
reveal pane \"${1}\"
activate
end tell" &>/dev/null
}

preferences_pane_anchor() { # open 'System Preferences' is specified pane and tab
  osascript -e "tell application \"System Preferences\"
reveal anchor \"${1}\" of pane \"${2}\"
activate
end tell" &>/dev/null
}

configure_zsh() { # make zsh default shell
  sudo -S sh -c 'echo "/usr/local/bin/zsh" >> /etc/shells' <<<"${sudo_password}" 2>/dev/null
  sudo -S chsh -s '/usr/local/bin/zsh' "${USER}" <<<"${sudo_password}" 2>/dev/null
}

configure_git() {
  git config --global user.name "${name}"
  git config --global user.email "${github_email}"
  git config --global github.user "${github_username}"
  git config --global credential.helper osxkeychain
  git config --global push.default simple
  git config --global rerere.enabled true
  git config --global rerere.autoupdate true
  git lfs install --system
}

link_airport() {
  ln -s /System/Library/PrivateFrameworks/Apple80211.framework/Versions/Current/Resources/airport "$command_files_dest/airport"
}

os_customize() {
  # intial message
  clear

  echo "This script will help configure the rest of macOS. It is divided in two parts:

  $(tput setaf 2)•$(tput sgr0) Commands that will change settings without needing intervetion.
  $(tput setaf 5)•$(tput sgr0) Commands that will require manual interaction.

  The first part will simply output what it is doing (the action itself, not the commands).

  The second part will open the appropriate panels/apps, inform what needs to be done, and pause. Unless prefixed with the message 'ALL TABS', all changes can be performed in the opened tab.
  After the changes are done, close the app and the script will continue.
  " | sed -E 's/ {2}//'

  # ask for 'sudo' authentication
  if sudo -n true 2>/dev/null; then
    echo
  else
    echo -n "$(tput bold)When you're ready to continue, insert your password. This is done upfront for the commands that require 'sudo'.$(tput sgr0) "
    sudo -v
  fi

  # first part
  # more options on
  # Close any open System Preferences panes, to prevent them from overriding
  # settings we're about to change
  osascript -e 'tell application "System Preferences" to quit'

  info 'Expand save panel by default.'
  defaults write NSGlobalDomain NSNavPanelExpandedStateForSaveMode -bool true
  defaults write NSGlobalDomain NSNavPanelExpandedStateForSaveMode2 -bool true

  info 'Expand print panel by default'
  defaults write NSGlobalDomain PMPrintingExpandedStateForPrint -bool true
  defaults write NSGlobalDomain PMPrintingExpandedStateForPrint2 -bool true

  info 'Automatically quit printer app once the print jobs complete'
  defaults write com.apple.print.PrintingPrefs "Quit When Finished" -bool true

  info 'Allow iOS Simulator to run in Full Screen'
  defaults write com.apple.iphonesimulator AllowFullscreenMode -bool true

  info 'Disable the “Are you sure you want to open this application?” dialog'
  defaults write com.apple.LaunchServices LSQuarantine -bool false

  info "Minimize windows into their application’s icon"
  defaults write com.apple.dock minimize-to-application -bool true

  info 'Reveal IP address, hostname, OS version, etc. when clicking the clock in the login window'
  sudo defaults write /Library/Preferences/com.apple.loginwindow AdminHostInfo HostName

  info 'Set language and text formats'
  defaults write NSGlobalDomain AppleLanguages -array "en"
  defaults write NSGlobalDomain AppleLocale -string "en_US@currency=USD"
  defaults write NSGlobalDomain AppleMeasurementUnits -string "Inches"
  defaults write NSGlobalDomain AppleMetricUnits -bool false

  info 'Enable full keyboard access for all controls.'
  # (e.g. enable Tab in modal dialogs)
  defaults write NSGlobalDomain AppleKeyboardUIMode -int 3

  info 'Set Home as the default location for new Finder windows.'
  defaults write com.apple.finder NewWindowTarget -string 'PfLo'
  defaults write com.apple.finder NewWindowTargetPath -string "file://${HOME}/"

  info 'Finder: allow quitting via ⌘ + Q; doing so will also hide desktop icons'
  defaults write com.apple.finder QuitMenuItem -bool true

  info 'Show all filename extensions in Finder.'
  defaults write NSGlobalDomain AppleShowAllExtensions -bool true

  info 'Show icons for hard drives, servers, and removable media on the desktop'
  defaults write com.apple.finder ShowExternalHardDrivesOnDesktop -bool true
  defaults write com.apple.finder ShowHardDrivesOnDesktop -bool true
  defaults write com.apple.finder ShowMountedServersOnDesktop -bool true
  defaults write com.apple.finder ShowRemovableMediaOnDesktop -bool true

  info 'Finder: show hidden files by default'
  defaults write com.apple.finder AppleShowAllFiles -bool true

  info 'Show item info near icons on the desktop.'
  /usr/libexec/PlistBuddy -c 'Set :DesktopViewSettings:IconViewSettings:showItemInfo true' "${HOME}/Library/Preferences/com.apple.finder.plist"

  info 'Increase grid spacing for icons on the desktop.'
  /usr/libexec/PlistBuddy -c 'Set :DesktopViewSettings:IconViewSettings:gridSpacing 100' "${HOME}/Library/Preferences/com.apple.finder.plist"

  info 'Increase the size of icons on the desktop.'
  /usr/libexec/PlistBuddy -c 'Set :DesktopViewSettings:IconViewSettings:iconSize 64' "${HOME}/Library/Preferences/com.apple.finder.plist"

  info 'Use list view in all Finder windows by default.'
  # Four-letter codes for the other view modes: 'icnv', 'Nlsv', 'Flwv'
  defaults write com.apple.finder FXPreferredViewStyle -string 'Nlsv'

  info 'Always show scrollbars'
  defaults write NSGlobalDomain AppleShowScrollBars -string "Always"

  info 'Increase sound quality for Bluetooth headphones/headsets'
  defaults write com.apple.BluetoothAudioAgent "Apple Bitpool Min (editable)" -int 255

  info 'When performing a search, search the current folder by default'
  defaults write com.apple.finder FXDefaultSearchScope -string "SCcf"

  info 'Disable the warning when changing a file extension'
  defaults write com.apple.finder FXEnableExtensionChangeWarning -bool false

  info 'Enable spring loading for directories'
  defaults write NSGlobalDomain com.apple.springing.enabled -bool true

  info 'Remove the spring loading delay for directories'
  defaults write NSGlobalDomain com.apple.springing.delay -float 0

  info 'Avoid creating .DS_Store files on network or USB volumes'
  defaults write com.apple.desktopservices DSDontWriteNetworkStores -bool true
  defaults write com.apple.desktopservices DSDontWriteUSBStores -bool true

  info "Use AirDrop over every interface"
  defaults write com.apple.NetworkBrowser BrowseAllInterfaces 1

  info 'Display full POSIX path as Finder window title'
  defaults write com.apple.finder _FXShowPosixPathInTitle -bool true

  info 'Expand the following File Info panes: “General”, “Open with”, and “Sharing & Permissions”'
  defaults write com.apple.finder FXInfoPanesExpanded -dict \
    General -bool true \
    OpenWith -bool true \
    Privileges -bool true

  info 'Prevent Time Machine from prompting to use new hard drives as backup volume'
  defaults write com.apple.TimeMachine DoNotOfferNewDisksForBackup -bool true

  info 'Use plain text mode for new TextEdit documents'
  defaults write com.apple.TextEdit RichText -int 0

  info 'Open and save files as UTF-8 in TextEdit'
  defaults write com.apple.TextEdit PlainTextEncoding -int 4
  defaults write com.apple.TextEdit PlainTextEncodingForWrite -int 4

  info 'Check for software updates daily, not just once per week'
  defaults write com.apple.SoftwareUpdate ScheduleFrequency -int 1

  info 'Download newly available updates in background'
  defaults write com.apple.SoftwareUpdate AutomaticDownload -int 1

  info 'Install System data files & security updates'
  defaults write com.apple.SoftwareUpdate CriticalUpdateInstall -int 1

  info 'Turn on app auto-update'
  defaults write com.apple.commerce AutoUpdate -bool true

  info 'Prevent Photos from opening automatically when devices are plugged in'
  defaults -currentHost write com.apple.ImageCapture disableHotPlug -bool true

  info 'Show the main window when launching Activity Monitor'
  defaults write com.apple.ActivityMonitor OpenMainWindow -bool true

  info 'Visualize CPU usage in the Activity Monitor Dock icon'
  defaults write com.apple.ActivityMonitor IconType -int 5

  info 'Show all processes in Activity Monitor'
  defaults write com.apple.ActivityMonitor ShowCategory -int 0

  info 'Sort Activity Monitor results by CPU usage'
  defaults write com.apple.ActivityMonitor SortColumn -string "CPUUsage"
  defaults write com.apple.ActivityMonitor SortDirection -int 0

  info 'Show the ~/Library folder, /Library, and /Volumes, and hide Applications, Documents, Music, Pictures, and Public.'
  chflags hidden "${HOME}/Applications"
  chflags nohidden "${HOME}/Library"
  chflags hidden "${HOME}/Documents"
  chflags hidden "${HOME}/Music"
  chflags hidden "${HOME}/Pictures"
  chflags hidden "${HOME}/Public"
  sudo chflags nohidden /Volumes
  sudo chflags nohidden /Library

  info 'Allow scroll gesture with ⌃ to zoom.'
  defaults write com.apple.universalaccess closeViewScrollWheelToggle -bool true
  defaults write com.apple.universalaccess HIDScrollZoomModifierMask -int 262144

  info 'Follow the keyboard focus while zoomed in'
  defaults write com.apple.universalaccess closeViewZoomFollowsFocus -bool true

  info 'Set hot corners.'
  # Possible values:
  #  0: no-op
  #  2: Mission Control
  #  3: Show application windows
  #  4: Desktop
  #  5: Start screen saver
  #  6: Disable screen saver
  #  7: Dashboard
  # 10: Put display to sleep
  # 11: Launchpad
  # 12: Notification Center
  # Top left screen corner → Put display to sleep
  defaults write com.apple.dock wvous-tl-corner -int 10
  # Top right screen corner → Put display to sleep
  defaults write com.apple.dock wvous-tr-corner -int 10
  # Bottom left screen corner → Desktop
  defaults write com.apple.dock wvous-bl-corner -int 4
  # Bottom right screen corner → Desktop
  defaults write com.apple.dock wvous-br-corner -int 4

  info 'Set Dock size and screen edge.'
  osascript -e 'tell application "System Events" to tell dock preferences to set properties to {dock size:0.4, screen edge:bottom}'

  info 'Set Dock to auto-hide.'
  osascript -e 'tell application "System Events" to set the autohide of the dock preferences to true'

  info "Add /usr/local/bin to GUI Apps' Path"
  sudo launchctl config user path "/usr/local/bin:$PATH"

  for app in 'Dock' 'Finder'; do
    killall "${app}" &>/dev/null
  done

  # second part
  # find values for System Preferences by opening the desired pane and running the following AppleScript:
  # tell application "System Preferences" to return anchors of current pane

  request 'Allow to send and receive SMS messages.' 'Messages'

  preferences_pane 'com.apple.preference.dock'
  request_preferences 'Always prefer tabs when opening documents.'

  preferences_pane_anchor 'Dictation' 'com.apple.preference.keyboard'
  request_preferences 'Turn on enhanced dictation and download other languages.'

  preferences_pane 'com.apple.preference.trackpad'
  request_preferences 'ALL TABS: Set Trackpad preferences.'

  preferences_pane 'com.apple.preference.mouse'
  request_preferences 'ALL TABS: Set Mouse preferences.'

  echo "Done!"

}
