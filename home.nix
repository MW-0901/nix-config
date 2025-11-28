{ config, pkgs, lib, ... }:

{
  home.activation.xhost = lib.hm.dag.entryAfter ["xserver"] ''
    ${pkgs.xhost}/bin/xhost +local:docker
  '';
  
  # Add this new section for the systemd service
  systemd.user.services.xhost-docker = {
    Unit = {
      Description = "Allow Docker containers to access X server";
      After = [ "graphical-session.target" ];
      PartOf = [ "graphical-session.target" ];
    };
    
    Service = {
      Type = "oneshot";
      ExecStart = "${pkgs.xhost}/bin/xhost +local:docker";
      RemainAfterExit = true;
      # Restart if it fails
      Restart = "on-failure";
      RestartSec = "5s";
    };
    
    Install = {
      WantedBy = [ "graphical-session.target" ];
    };
  };

  # Rest of your existing home.nix configuration
  home.username = "mark";
  home.homeDirectory = "/home/mark";
  home.enableNixpkgsReleaseCheck = false;
  home.stateVersion = "25.11";

  programs.home-manager.enable = true;
  programs.zsh = {
    enable = true;
    oh-my-zsh = {
      enable = true;
      theme = "bira";
      plugins = [ "git" ];
    };
    syntaxHighlighting.enable = true;
    autosuggestion.enable = true;
    enableCompletion = true;
  };
  programs.zsh.shellAliases = {
    cat = "bat";
    ccat = "/run/current-system/sw/bin/cat";
    ls = "eza";
    grep = "rg";
  };
  programs.bat.enable = true;
  programs.eza.enable = true;
  programs.ripgrep.enable = true;
}
