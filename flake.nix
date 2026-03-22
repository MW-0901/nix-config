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

    niri = {
      url = "github:sodiboo/niri-flake";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    walker = {
      url = "github:abenz1267/walker";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    stylix = {
      url = "github:nix-community/stylix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

  };

  outputs = { self, nixpkgs, home-manager, nvf, niri, walker, stylix, ... }:
    let
      lib = nixpkgs.lib;
      system = "x86_64-linux";
      pkgs = import nixpkgs {
        inherit system;
        config = {
          allowUnfree = true;
          installDocs = false;
          debugOutputs = false;
          separateDebugInfo = false;
        };
      };
    in {
      # Your global packages
      packages.${system}.default = pkgs.buildEnv {
        name = "global-packages";
        paths = with pkgs; [
          firefox
          git
          curl
          wget
          gnupg
          pinentry-qt
          gh
          doas
          home-manager
          fd
          tree
          powertop
          fastfetch
          docker-compose
          xhost
          nixfmt
          nil
          clang
          clang-tools
          nixd
          nftables
          wl-clipboard-rs
          mesa
          xwayland-satellite
          ifuse
          libimobiledevice
          impala
          vscodium
          mpv
          swaylock
          dhcpcd
          nh
          discord
          signal-desktop
          resources
          python3
          zoom-us
          easyeffects
          ispell
          duperemove
          mako
          libnotify
          jq
          prismlauncher
          javaPackages.compiler.openjdk21
          btop
          screen
          uv
          kdePackages.okular
          helix
          veracrypt
          at
          cacert
          texlive.combined.scheme-medium
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
            # Use the same pkgs instance with allowUnfree
            nixpkgs.pkgs = pkgs;
            
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.users.mark = {
              imports = [
                nvf.homeManagerModules.default
                stylix.homeModules.stylix
                niri.homeModules.niri
                walker.homeManagerModules.default
                ./home.nix
              ];
            };
          }
        ];
      };
      nixosConfigurations.iso = nixpkgs.lib.nixosSystem {
        inherit system;
        specialArgs = {
          globalPackages = pkgs.buildEnv { name = "empty"; paths = []; };
        };
        modules = [
          "${nixpkgs}/nixos/modules/installer/cd-dvd/installation-cd-minimal.nix"
          ./configuration.nix
          ./hardware-configuration.nix
          home-manager.nixosModules.home-manager
          {
            nixpkgs.pkgs = pkgs;
            isoImage.squashfsCompression = "zstd -Xcompression-level 6";
            boot.resumeDevice = lib.mkForce "";
            boot.kernelParams = lib.mkForce [];
            swapDevices = lib.mkForce [];

            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.users.mark = {
              imports = [
                nvf.homeManagerModules.default
                stylix.homeModules.stylix
                niri.homeModules.niri
                walker.homeManagerModules.default
                ./home.nix
              ];
            };
          }
        ];
      };
    };
}
