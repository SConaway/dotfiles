{
  description = "NixOS Hive";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.11";
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixos-unstable";
    colmena = {
      url = "github:zhaofengli/colmena";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    darwin = {
      url = "github:lnl7/nix-darwin";
      inputs.nixpkgs.follows = "nixpkgs-unstable";
    };
    home-manager = {
      url = "github:nix-community/home-manager/release-25.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    home-manager-unstable = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs-unstable";
    };
    mac-app-util = {
      url = "github:hraban/mac-app-util";
      inputs.nixpkgs.follows = "nixpkgs-unstable";
    };
    determinate.url = "https://flakehub.com/f/DeterminateSystems/determinate/3";
  };

  outputs =
    {
      self,
      nixpkgs,
      nixpkgs-unstable,
      colmena,
      darwin,
      home-manager,
      home-manager-unstable,
      mac-app-util,
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

      hmConfig = {
        home-manager.useGlobalPkgs = true;
        home-manager.useUserPackages = true;
        home-manager.extraSpecialArgs = { inherit inputs; };
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
            mac-app-util.darwinModules.default
            home-manager-unstable.darwinModules.home-manager
            hmConfig
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
            ca-meshview = import nixpkgs-unstable {
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
            hmConfig
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
            home-manager-unstable.nixosModules.home-manager
            hmConfig
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
            hmConfig
          ];
          deployment.targetHost = "ca-qb";
          deployment.targetUser = "steven";
          deployment.tags = [
            "ca"
            "linux"
          ];
        };

        id-frigate = {
          imports = [
            ./hosts/id-frigate/default.nix
            home-manager.nixosModules.home-manager
            hmConfig
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
            hmConfig
          ];
          deployment.targetHost = "id-tailscale";
          deployment.targetUser = "steven";
          deployment.tags = [
            "id"
            "linux"
          ];
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
