{ pkgs, ... }:

{
  stylix.enable = true;
  stylix.polarity = "dark";
  stylix.base16Scheme = "${pkgs.base16-schemes}/share/themes/dracula.yaml";
  stylix.targets.foot.enable = false;
  stylix.targets.emacs.enable = false;
  stylix.targets.qutebrowser.enable = false;
}
