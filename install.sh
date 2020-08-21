#! /usr/bin/env bash
# shellcheck disable=SC1090,SC2034,SC2154,SC2155

curl --progress-bar --location 'https://github.com/sconaway/dotfiles/archive/master.zip' | ditto -xk - '/tmp' # download and extract script

# source all shell scripts
for shell_script in '/tmp/dotfiles-master/scripts/'*.sh; do
  source "${shell_script}"
done

# run and log errors to file (but still show them when they happen)
readonly error_log="${HOME}/Desktop/install_errors.log"
bash /tmp/dotfiles-master/main_install.sh 2> >(tee "${error_log}")
