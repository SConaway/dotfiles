{ pkgs, lib, ... }:

let
  leaf = pkgs.rustPlatform.buildRustPackage {
    pname = "leaf";
    version = "1.24.0";
    src = pkgs.fetchFromGitHub {
      owner = "RivoLink";
      repo = "leaf";
      rev = "1.24.0";
      hash = "sha256-wqp2VUBqYFk9eLrVuNqmUyEPINYhuWf5Iq8Ye0oicEA=";
    };
    cargoHash = "sha256-pg4B+wtZ5EUMX9pacNoR51VMewdcqEe4il1AD5Uhwlc=";
  };
in
{
  environment.systemPackages = [ leaf ];
}
