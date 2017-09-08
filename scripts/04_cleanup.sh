#! /bin/bash
cleanup_brew() {
  rm -rf "$(brew --cache)"
}

cleanup_error_log() {
  sed -i '' -E '/^Password: /d;/#.*%/d;/\* \[new/d;/Cloning into/d;/Should we execute post_install_script/d' "${error_log}"
}

move_manual_action_files() {
  mv "${command_files}" "${command_files_dest}"
  mv "${helper_files}" "${post_install_files}"
}

final_message() {
  clear

  echo "All the automated scripts have now finished.
    'stderr' has been logged to '${error_log}'.

    There are still a few operations that should be completed manually.

    - In '${post_install_files}', there are configurations that will need to be manually applied.
      File names should be self-explanatory.
    - There is also '${post_install_script}', that pertains to changes to the behaviour of the OS itself.
      Read it to make sure its options are still desirable (or needed, even).
  " | sed -E 's/ {4}//'
}
