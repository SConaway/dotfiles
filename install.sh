#! /bin/bash
# run and log errors to file (but still show them when they happen)
readonly error_log="${HOME}/Desktop/install_errors.log"
bash ./main_install.sh "$1" 2> >(tee "${error_log}")
