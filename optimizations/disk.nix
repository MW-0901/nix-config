{ config, pkgs, ... }:

{
  nix.settings.auto-optimise-store = true;

  nix.gc = {
    automatic = true;
    dates = "daily";
    options = "--delete-older-than 7d --max-keep=10";
  };

  documentation = {
    enable = false;
    doc.enable = false;
    man.enable = false;
    info.enable = false;
  };

  nixpkgs.config = {
    installDocs = false;

    debugOutputs = false;

    separateDebugInfo = false;
  };

  nix.settings.narinfo-cache-positive-ttl = 86400;
  nix.settings.narinfo-cache-negative-ttl = 86400;
}
