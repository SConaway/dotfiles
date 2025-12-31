{
  description = "NixOS Hive";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    colmena = {
      url = "github:zhaofengli/colmena";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    darwin = {
      url = "github:lnl7/nix-darwin";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, colmena, darwin, ... }: 
    let
      supportedSystems = [ "x86_64-linux" "aarch64-linux" "x86_64-darwin" "aarch64-darwin" ];
      forAllSystems = nixpkgs.lib.genAttrs supportedSystems;
      pkgs = forAllSystems (system: nixpkgs.legacyPackages.${system});
    in {
      # macOS Configuration
      darwinConfigurations = {
        "mac" = darwin.lib.darwinSystem {
          system = "aarch64-darwin"; # Change to x86_64-darwin if on Intel Mac
          modules = [ ./hosts/mac/default.nix ];
        };
      };

      # NixOS Hive Configuration
      colmenaHive = colmena.lib.makeHive {
        meta = {
          nixpkgs = import nixpkgs {
            system = "x86_64-linux";
          };
        };

        ca-media = {
          imports = [ ./hosts/ca-media/default.nix ];
          deployment.targetHost = "ca-media";
          deployment.targetUser = "steven";
          deployment.tags = [ "ca" "linux" ];
        };

        ca-meshview = {
          imports = [ ./hosts/ca-meshview/default.nix ];
          deployment.targetHost = "ca-meshview";
          deployment.targetUser = "steven";
          deployment.tags = [ "ca" "linux" ];
        };

        ca-qb = {
          imports = [ ./hosts/ca-qb/default.nix ];
          deployment.targetHost = "ca-qb";
          deployment.targetUser = "steven";
          deployment.tags = [ "ca" "linux" ];
        };

        id-frigate = {
          imports = [ ./hosts/id-frigate/default.nix ];
          deployment.targetHost = "id-frigate";
          deployment.targetUser = "steven";
          deployment.tags = [ "id" "linux" ];
        };

        id-tailscale = {
          imports = [ ./hosts/id-tailscale/default.nix ];
          deployment.targetHost = "id-tailscale";
          deployment.targetUser = "steven";
          deployment.tags = [ "id" "linux" ];
        };
      };

      devShells = forAllSystems (system: {
        default = pkgs.${system}.mkShell {
          buildInputs = [
            colmena.packages.${system}.colmena
          ];
        };
      });
    };
}
