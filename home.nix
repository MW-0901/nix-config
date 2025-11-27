{ config, pkgs, ... }:

{
  # Home Manager needs a bit of information about you and the
  # paths it should manage.
  home.username = "mark";
  home.homeDirectory = "/home/mark";
  home.enableNixpkgsReleaseCheck = false;
  # This value determines the Home Manager release that your
  # configuration is compatible with. This helps avoid breakage
  # when a new Home Manager release introduces backwards
  # incompatible changes.
  #
  # You can update Home Manager without changing this value. See
  # the Home Manager release notes for a list of state version
  # changes in each release.
  home.stateVersion = "25.11";

  # Let Home Manager install and manage itself.
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
    ls = "eza";
    grep = "rg";
  };
  programs.bat.enable = true;
  programs.eza.enable = true;
  programs.ripgrep.enable = true;
}
