{
  description = "NixOS Hive";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-26.05";
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixos-unstable";
    nixpkgs-unstable-small.url = "github:NixOS/nixpkgs/nixos-unstable-small";
    colmena = {
      url = "github:zhaofengli/colmena";
      inputs.nixpkgs.follows = "nixpkgs-unstable";
    };
    darwin = {
      url = "github:lnl7/nix-darwin";
      inputs.nixpkgs.follows = "nixpkgs-unstable-small";
    };
    home-manager = {
      url = "github:nix-community/home-manager/release-26.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    home-manager-unstable = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs-unstable";
    };
    determinate.url = "https://flakehub.com/f/DeterminateSystems/determinate/3";
    agenix = {
      url = "github:ryantm/agenix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    disko = {
      url = "github:nix-community/disko";
      inputs.nixpkgs.follows = "nixpkgs-unstable";
    };
    llm-agents = {
      url = "github:numtide/llm-agents.nix";
      inputs.nixpkgs.follows = "nixpkgs-unstable";
    };
    zsh-patina = {
      url = "github:michel-kraemer/zsh-patina";
      inputs.nixpkgs.follows = "nixpkgs-unstable";
    };
  };

  outputs =
    {
      self,
      nixpkgs,
      nixpkgs-unstable,
      nixpkgs-unstable-small,
      colmena,
      darwin,
      home-manager,
      home-manager-unstable,
      agenix,
      disko,
      llm-agents,
      ...
    }@inputs:
    let
      supportedSystems = [
        "x86_64-linux"
        "aarch64-linux"
        "x86_64-darwin"
        "aarch64-darwin"
      ];
      forAllSystems = nixpkgs.lib.genAttrs supportedSystems;
      pkgs = forAllSystems (system: nixpkgs.legacyPackages.${system});

      mkHmConfig = hostname: {
        home-manager.useGlobalPkgs = true;
        home-manager.useUserPackages = true;
        home-manager.extraSpecialArgs = { inherit inputs hostname; };
        home-manager.users.steven = import ./users/steven/default.nix;
      };
    in
    {
      # macOS Configuration
      darwinConfigurations = {
        "mac" = darwin.lib.darwinSystem {
          system = "aarch64-darwin"; # Change to x86_64-darwin if on Intel Mac
          specialArgs = { inherit inputs; };
          modules = [
            ./hosts/mac/default.nix
            home-manager-unstable.darwinModules.home-manager
            (mkHmConfig "mac")
            inputs.determinate.darwinModules.default
          ];
        };
      };

      # NixOS Hive Configuration
      colmenaHive = colmena.lib.makeHive {
        meta = {
          nixpkgs = import nixpkgs {
            system = "x86_64-linux";
          };
          nodeNixpkgs = {
            ca-media = import nixpkgs {
              system = "x86_64-linux";
            };
            ca-meshview = import nixpkgs {
              system = "x86_64-linux";
            };
            ca-qb = import nixpkgs {
              system = "x86_64-linux";
            };
            ca-work = import nixpkgs-unstable {
              system = "x86_64-linux";
            };
            ca-lyfe = import nixpkgs {
              system = "x86_64-linux";
            };
            nixpi = import nixpkgs {
              system = "aarch64-linux";
            };
            id-attic = import nixpkgs {
              system = "x86_64-linux";
            };
            id-frigate = import nixpkgs {
              system = "x86_64-linux";
            };
            id-tailscale = import nixpkgs {
              system = "x86_64-linux";
            };
            small = import nixpkgs-unstable {
              system = "x86_64-linux";
            };
          };
          specialArgs = { inherit inputs; };

        };
        defaults = {
          deployment.buildOnTarget = true;
        };

        ca-media = {
          imports = [
            ./hosts/ca-media/default.nix
            home-manager.nixosModules.home-manager
            (mkHmConfig "ca-media")
          ];
          deployment.targetHost = "ca-media";
          deployment.targetUser = "steven";
          deployment.tags = [
            "ca"
            "linux"
          ];
        };

        ca-meshview = {
          imports = [
            ./hosts/ca-meshview/default.nix
            home-manager.nixosModules.home-manager
            (mkHmConfig "ca-meshview")
          ];
          deployment.targetHost = "ca-meshview";
          deployment.targetUser = "steven";
          deployment.tags = [
            "ca"
            "linux"
          ];
        };

        ca-qb = {
          imports = [
            ./hosts/ca-qb/default.nix
            home-manager.nixosModules.home-manager
            (mkHmConfig "ca-qb")
          ];
          deployment.targetHost = "ca-qb";
          deployment.targetUser = "steven";
          deployment.tags = [
            "ca"
            "linux"
          ];
        };

        ca-work = {
          imports = [
            ./hosts/ca-work/default.nix
            home-manager-unstable.nixosModules.home-manager
            (mkHmConfig "ca-work")
          ];
          deployment.targetHost = "ca-work";
          deployment.targetUser = "steven";
          deployment.allowLocalDeployment = true;
          deployment.tags = [
            "ca"
            "linux"
          ];
        };

        nixpi = {
          imports = [
            ./hosts/nixpi/default.nix
            home-manager.nixosModules.home-manager
            (mkHmConfig "nixpi")
          ];
          deployment.targetHost = "nixpi";
          deployment.targetUser = "steven";
          deployment.tags = [
            "pi"
            "linux"
          ];
        };

        ca-lyfe = {
          imports = [
            ./hosts/ca-lyfe/default.nix
            home-manager.nixosModules.home-manager
            (mkHmConfig "ca-lyfe")
          ];
          deployment.targetHost = "ca-lyfe";
          deployment.targetUser = "steven";
          deployment.tags = [
            "ca"
            "linux"
          ];
        };

        id-attic = {
          imports = [
            ./hosts/id-attic/default.nix
            home-manager.nixosModules.home-manager
            (mkHmConfig "id-attic")
          ];
          deployment.targetHost = "id-attic";
          deployment.targetUser = "root";
          deployment.tags = [
            "id"
            "linux"
          ];
        };

        id-frigate = {
          imports = [
            ./hosts/id-frigate/default.nix
            home-manager.nixosModules.home-manager
            (mkHmConfig "id-frigate")
          ];
          deployment.targetHost = "id-frigate";
          deployment.targetUser = "steven";
          deployment.tags = [
            "id"
            "linux"
          ];
        };

        id-tailscale = {
          imports = [
            ./hosts/id-tailscale/default.nix
            home-manager.nixosModules.home-manager
            (mkHmConfig "id-tailscale")
          ];
          deployment.targetHost = "id-tailscale";
          deployment.targetUser = "steven";
          deployment.tags = [
            "id"
            "linux"
          ];
        };

        small = {
          imports = [
            ./hosts/small/default.nix
            home-manager-unstable.nixosModules.home-manager
            (mkHmConfig "small")
            disko.nixosModules.disko
          ];
          deployment.targetHost = "small";
          deployment.targetUser = "steven";
          deployment.tags = [
            "linux"
          ];
        };
      };

      # enable `sudo nixos-install --flake  .#<host>`
      nixosConfigurations = self.colmenaHive.nodes;

      devShells = forAllSystems (system: {
        default = pkgs.${system}.mkShell {
          buildInputs = [
            colmena.packages.${system}.colmena
            agenix.packages.${system}.default
          ];
        };
      });
    };
}
