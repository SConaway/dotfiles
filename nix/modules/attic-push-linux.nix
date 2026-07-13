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

  systemd.services.attic-watch-store = {
    description = "Push newly-built store paths to the attic cache";
    wantedBy = [ "multi-user.target" ];
    after = [
      "network-online.target"
      "atticd.service"
    ];
    wants = [ "network-online.target" ];
    serviceConfig = {
      ExecStart = watchScript;
      Restart = "on-failure";
      RestartSec = 10;
      StateDirectory = "attic-watch-store";
    };
  };
}
