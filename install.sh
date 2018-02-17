#! /bin/bash

if [[ $# -eq 2 ]] ; then
  echo "Running on CI"
  for shell_script in './scripts/'*.sh; do
    source "${shell_script}"
  done

  # run and log errors to file (but still show them when they happen)
  readonly error_log="${HOME}/Desktop/install_errors.log"
  bash ./main_install.sh "$2" 2> >(tee "${error_log}")
else
  #curl --progress-bar --location 'https://github.com/sconaway/dotfiles/archive/master.zip' | ditto -xk - '/tmp' # download and extract script

  # source all shell scripts
  for shell_script in './scripts/'*.sh; do
  #for shell_script in '/tmp/dotfiles-master/scripts/'*.sh; do
    source "${shell_script}"
  done

  # run and log errors to file (but still show them when they happen)
  readonly error_log="${HOME}/Desktop/install_errors.log"
  #bash /tmp/dotfiles-master/main_install.sh 2> >(tee "${error_log}")
  bash ./main_install.sh 2> >(tee "${error_log}")
fi
