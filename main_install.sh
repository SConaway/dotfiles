#! /usr/bin/env bash
# shellcheck disable=SC1090,SC2034,SC2154,SC2155

caffeinate &# prevent computer from going to sleep

clear

for shell_script in './scripts/'*.sh; do
  source "${shell_script}"
done
on_ci=false

initial_setup
ask_details
sync_icloud
update_system

install_brew
install_python
install_ruby
install_node
install_zsh

install_brew_stuff

configure_zsh
configure_git
link_airport
os_customize

cleanup_brew
cleanup_error_log

killall caffeinate # computer can go back to sleep

final_message
