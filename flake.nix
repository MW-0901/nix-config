{
  description = "All my global nixos packages :)";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
  };

  outputs = { self, nixpkgs, ... }:
    let
      system = "x86_64-linux";
      pkgs = import nixpkgs { inherit system; };
    in {
      # default attribute is a list of packages
      packages.${system}.default = pkgs.buildEnv {
        name = "global-packages";
        paths = [
          pkgs.firefox
          pkgs.git
          pkgs.curl
	  pkgs.wget
	  pkgs.gnupg
	  pkgs.pinentry-qt
	  pkgs.neovim
	  pkgs.gh
	  pkgs.doas
        ];
      };
    };
}
