{ pkgs, lib, ... }:

let
  leaf = pkgs.rustPlatform.buildRustPackage {
    pname = "leaf";
    version = "1.27.1";
    src = pkgs.fetchFromGitHub {
      owner = "RivoLink";
      repo = "leaf";
      rev = "1.27.1";
      hash = "sha256-JYKahP0dEineUKziR2uuxrVpZagtZr912m4Y4OBoloo=";
    };
    cargoHash = "sha256-svfLThsZt3brVTlAloZizJuGlmnaiQIwjANg3oBCTIk=";
  };
in
{
  environment.systemPackages = [ leaf ];
}
