#! /usr/bin/env bash
# shellcheck disable=SC1090,SC2034,SC2154,SC2155
cleanup_brew() {
  rm -rf "$(brew --cache)"
}

cleanup_error_log() {
  sed -i '' -E '/^Password: /d;/#.*%/d;/\* \[new/d;/Cloning into/d;/Should we execute post_install_script/d' "${error_log}"
}

final_message() {
  clear

  echo "All the automated scripts have now finished.
    'stderr' has been logged to '${error_log}'.
    " | sed -E 's/ {4}//'
}
