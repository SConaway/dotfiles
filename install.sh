#! /bin/bash

curl --progress-bar --location 'https://github.com/sconaway/dotfiles/archive/master.zip' | ditto -xk - '/tmp' # download and extract script

# run and log errors to file (but still show them when they happen)
readonly error_log="${HOME}/Desktop/install_errors.log"
bash /tmp/dotfiles-master/main_install.sh "$1" 2> >(tee "${error_log}")
