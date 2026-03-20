{
  config,
  pkgs,
  lib,
  ...
}:

{
  programs.niri = {
    settings = {
      prefer-no-csd = true;
      layout = {
        gaps = 0;
        border = {
          enable = false;
        };
        focus-ring = {
          enable = false;
        };
      };

      outputs.eDP-1.variable-refresh-rate = true;
      outputs.DP-3.mode = {
        height = 1440;
        width = 2560;
        refresh = 180.002;
      };
      outputs.DP-4.mode = {
        height = 1440;
        width = 2560;
        refresh = 180.002;
      };

      input = {
        keyboard = {
          xkb = {
            layout = "us";
          };
        };
        mouse.scroll-factor = 0.3;
      };

      binds = with config.lib.niri.actions; {
        "Mod+Return".action = spawn "emacsclient" "-a" "" "-c" "-e" "(progn (eshell) (text-scale-set 2))";
        "Shift+Mod+Return".action = spawn "emacsclient" "-a" "" "-c" "-e" "(progn (eshell t) (text-scale-set 2))";
        "Shift+Alt+Return".action = spawn "foot";
        "Alt+Return".action = spawn "emacsclient" "-a" "" "-c" "-e" "(eat)";
        "Mod+Q".action = close-window;
        "Mod+F".action = maximize-column;
        "Mod+Shift+X".action = quit;
        "Mod+Shift+Slash".action = show-hotkey-overlay;
        "Mod+Shift+A".action = open-overview;
        "Mod+A".action = focus-column-left;
        "Mod+D".action = focus-column-right;
        "Mod+W".action = focus-window-or-workspace-up;
        "Mod+S".action = focus-window-or-workspace-down;
        "Mod+Space".action = spawn "walker";
        "Mod+Shift+S".action = spawn "niri" "msg" "action" "screenshot-window";
        "Shift+Alt+S".action = spawn "niri" "msg" "action" "screenshot";
        "Mod+B".action = spawn "firefox" "-P" "default";
        "Shift+Mod+B".action = spawn "firefox" "-P" "School";
        "Shift+Mod+W".action = spawn "alacritty" "--class" "wifi" "-e" "impala";
        "Mod+Down".action = move-window-down-or-to-workspace-down;
        "Mod+Up".action = move-window-up-or-to-workspace-up;
        "Mod+Left".action = move-column-left;
        "Mod+Right".action = move-column-right;
        "XF86AudioRaiseVolume".action = spawn "swayosd-client" "--output-volume=raise";
        "XF86AudioLowerVolume".action = spawn "swayosd-client" "--output-volume=lower";
        "XF86AudioMute".action = spawn "swayosd-client" "--output-volume=mute-toggle";
        "XF86MonBrightnessUp".action = spawn "swayosd-client" "--brightness=+1";
        "XF86MonBrightnessDown".action = spawn "swayosd-client" "--brightness=-1";
        "Shift+Mod+F".action = spawn "dolphin";
        "Shift+Mod+Q".action = spawn "swaylock";
        "Shift+Mod+D".action = spawn "makoctl" "dismiss";
        "Alt+B".action = spawn "qutebrowser";
      };
      spawn-at-startup = [
        {
          argv = [
            "emacsclient"
            "-a"
            ""
            "-c"
            "-e"
            "(make-frame-invisible nil t)"
          ];
        }
        {
          argv = [
            "swaybg"
            "--image"
            "${import ./backgrounds/default.nix}"
          ];
        }
      ];
      window-rules = [
        {
          matches = [ { app-id = "Alacritty"; } ];
          opacity = 0.8;
          focus-ring.enable = false;
          draw-border-with-background = false;
          border.width = 0;

        }
        {
          matches = [ { app-id = "wifi"; } ];
          opacity = 0.9;
          focus-ring.enable = false;
          draw-border-with-background = false;
          open-floating = true;
          border.width = 0;
        }
      ];
    };
  };
}
