{ pkgs, ... }:

let
  backgroundImage = import ./backgrounds/default.nix;
in
{
  home.file.".backgrounds".source = ./backgrounds;
  home.packages = with pkgs; [
    swaybg
  ];
}
