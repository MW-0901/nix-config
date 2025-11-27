{ config, pkgs, lib, ... }:

{
  virtualisation.docker.enable = true;
  users.users.mark.extraGroups = [ "docker" ];
};
