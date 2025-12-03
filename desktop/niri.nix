{
  config,
  pkgs,
  lib,
  ...
}:

{
  programs.niri = {
    settings = {
      layout = {
        gaps = 6;
        border.width = 2;
      };

      input = {
        keyboard = {
          xkb = {
            layout = "us";
          };
        };
      };

      binds = with config.lib.niri.actions; {
        "Mod+Return".action = spawn "alacritty";
        "Mod+Q".action = close-window;
        "Mod+M".action = maximize-column;
        "Mod+Shift+R".action = quit;
        "Mod+Shift+Slash".action = show-hotkey-overlay;
      };
    };
  };
}
