{ pkgs, lib, ... }:

let
  leaf = pkgs.rustPlatform.buildRustPackage {
    pname = "leaf";
    version = "1.21.0";
    src = pkgs.fetchFromGitHub {
      owner = "RivoLink";
      repo = "leaf";
      rev = "1.21.0";
      hash = "sha256-i9LVpNhSRXm4eW5xEOANZPCtnExPzgO+0fDZzg634Ic=";
    };
    cargoHash = "sha256-7iw2d5iySMtVUSWptqeO8ZSIMsufdiew6MsxA08PI7U=";
  };
in
{
  environment.systemPackages = [ leaf ];
}
