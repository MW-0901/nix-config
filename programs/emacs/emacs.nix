{ config, pkgs, ... }:

let
  emacsPkg = pkgs.emacs;
  emacsPkgs = pkgs.emacsPackagesFor emacsPkg;
  emacsConfig = ./init.el;
  emacsModulesDir = ./modules;
in
{
  programs.emacs = {
    enable = true;

    package = emacsPkgs.emacsWithPackages (epkgs: with epkgs; [
      lsp-mode
      lsp-java
      dap-mode
      use-package
      base16-theme
      rust-mode
      doom-themes
      rustic
      which-key
      marginalia
      smartparens
      multiple-cursors
      expand-region
      ace-window
      avy
      vertico
      nix-mode
      magit
      forge
      projectile
      diff-hl
      vterm
      corfu
      paredit
      simple-httpd
      company
      git-timemachine
      undo-tree
      rainbow-delimiters
      flycheck
      helpful
      embark-consult
      aggressive-indent
      orderless
      python-mode
      svelte-mode
      typescript-mode
      prettier-js
      groovy-mode
      gradle-mode
      inheritenv
      try
      ranger
      atomic-chrome
      elfeed
      eat
      eshell-syntax-highlighting
      eshell-z
      xterm-color
      envrc
      pyvenv
      request
      circe
      auctex
      cdlatex
      hydra
    ]);
  };

  home.file.".emacs.d/init.el".source = emacsConfig;

  home.file.".emacs.d/modules" = {
    source = emacsModulesDir;
    recursive = true;
  };
}
