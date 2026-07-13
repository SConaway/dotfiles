{ config, pkgs, ... }:

let
  server = "http://id-attic:8080";
  cache = "homelab";
  watchScript = pkgs.writeShellScript "attic-watch-store" ''
    set -eu
    export HOME="$STATE_DIRECTORY"
    ${pkgs.attic-client}/bin/attic login ${cache} ${server} "$(cat ${config.age.secrets.attic-push-token.path})"
    exec ${pkgs.attic-client}/bin/attic watch-store ${cache}
  '';
in
{
  age.secrets.attic-push-token.file = ../secrets/attic-push-token.age;

  launchd.daemons.attic-watch-store = {
    serviceConfig = {
      ProgramArguments = [ "${watchScript}" ];
      KeepAlive = true;
      RunAtLoad = true;
      EnvironmentVariables.STATE_DIRECTORY = "/var/lib/attic-watch-store";
      StandardOutPath = "/var/log/attic-watch-store.log";
      StandardErrorPath = "/var/log/attic-watch-store.log";
    };
  };

  system.activationScripts.atticWatchStoreStateDir.text = ''
    mkdir -p /var/lib/attic-watch-store
  '';
}
