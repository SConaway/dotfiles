{ pkgs, lib, ... }:

let
  leaf = pkgs.rustPlatform.buildRustPackage {
    pname = "leaf";
    version = "1.26.1";
    src = pkgs.fetchFromGitHub {
      owner = "RivoLink";
      repo = "leaf";
      rev = "1.26.1";
      hash = "sha256-faZ3yiAdPbN1Pxf7Gss62eYUJzaJ3ZF5BZyCVqHOC4s=";
    };
    cargoHash = "sha256-evHpyavHLJxStN8ZYDetwzxh18eQX9Nq3KL3kudk7dI=";
  };
in
{
  environment.systemPackages = [ leaf ];
}
