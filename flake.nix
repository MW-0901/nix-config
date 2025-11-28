{
  description = "NixOS system configuration";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nvf = {
      url = "github:notashelf/nvf";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, home-manager, nvf, ... }:
    let
      system = "x86_64-linux";
      pkgs = import nixpkgs {
        inherit system;
        config.allowUnfree = true;
      };
    in {
      # Your global packages
      packages.${system}.default = pkgs.buildEnv {
        name = "global-packages";
        paths = [
          pkgs.firefox
          pkgs.git
          pkgs.curl
          pkgs.wget
          pkgs.gnupg
          pkgs.pinentry-qt
          pkgs.gh
          pkgs.doas
          pkgs.home-manager
          pkgs.fd
          pkgs.tree
          pkgs.powertop
          pkgs.fastfetch
          pkgs.zed-editor
          pkgs.docker-compose
          pkgs.docker-buildx
          pkgs.xhost
          pkgs.nixfmt
        ];
      };

      # Your NixOS system
      nixosConfigurations.nixos = nixpkgs.lib.nixosSystem {
        inherit system;
        specialArgs = {
          globalPackages = self.packages.${system}.default;
        };
        modules = [
          ./configuration.nix
          ./hardware-configuration.nix
          home-manager.nixosModules.home-manager
          {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.users.mark = {
                imports = [
                    nvf.homeManagerModules.default
                    ./home.nix
                ];
            };
          }
        ];
      };
    };
}
