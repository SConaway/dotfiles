{ pkgs, lib, ... }:

let
  leaf = pkgs.rustPlatform.buildRustPackage {
    pname = "leaf";
    version = "1.25.0";
    src = pkgs.fetchFromGitHub {
      owner = "RivoLink";
      repo = "leaf";
      rev = "1.25.0";
      hash = "sha256-OSx797tkwjKU9j+0AhQIT7uLM75PzHVw12d5LG6vT3Q=";
    };
    cargoHash = "sha256-rEISBL5vWYP5UKFKWLA2RxlqDBFTz8qPpiPOfxeNUFQ=";
  };
in
{
  environment.systemPackages = [ leaf ];
}
