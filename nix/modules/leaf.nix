{ pkgs, lib, ... }:

let
  leaf = pkgs.rustPlatform.buildRustPackage {
    pname = "leaf";
    version = "1.28.1";
    src = pkgs.fetchFromGitHub {
      owner = "RivoLink";
      repo = "leaf";
      rev = "1.28.1";
      hash = "sha256-xAO52Xhu2QOXzg/TJubTguJ7URddKnQekACnvytx5Qw=";
    };
    cargoHash = "sha256-Y+sOyHOSEjKW+NEpSjZgqJwXH3IOSFMBGM84oytRNsc=";
  };
in
{
  environment.systemPackages = [ leaf ];
}
