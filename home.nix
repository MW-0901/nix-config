{ config, pkgs, lib, ... }:

{

  imports = [
    ./programs/neovim.nix
    ./programs/emacs/emacs.nix
    ./programs/alacritty.nix
    ./programs/tmux.nix
    ./desktop/niri.nix
    ./desktop/walker.nix
    ./desktop/background.nix
    ./desktop/stylix.nix
  ];
  programs.niri.package = pkgs.niri;
  programs.zoxide = {
    enable = true;
    enableZshIntegration = true;
  };
  programs.qutebrowser = {
    enable = true;
    settings = {
      statusbar.widgets = ["keypress" "url" "scroll" "history" "tabs" "clock"];
    };
  };
  home.packages = with pkgs; [
    nerd-fonts.hack
  ];
  programs.foot = {
    enable = true;
    settings = {
      main = {
        font = lib.mkForce "Hack:size=18";
      };
    };
  };

  home.file."Projects/.keep".text = "";

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
      Restart = "on-failure";
      RestartSec = "5s";
    };

    Install = {
      WantedBy = [ "graphical-session.target" ];
    };
  };
  programs.direnv = {
    enable = true;
    nix-direnv.enable = true;
  };

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
    sessionVariables = {
      DIRENV_WARN_TIMEOUT = "1m";
    };
  };
  programs.zsh.shellAliases = {
    cat = "bat";
    ccat = "/run/current-system/sw/bin/cat";
    ls = "eza";
    grep = "rg";
    r = "nix run";
    b = "nix build";
    e = "emacsclient -c -a \"\" & disown";
    es = "emacsclient -nw -a \"\" -e \"(eshell)\"";
  };
  programs.bat.enable = true;
  programs.eza.enable = true;
  programs.ripgrep.enable = true;
  services.mako = {
    enable = true;
  };
  systemd.user.services.battery-monitor = {
    Unit = {
      Description = "Battery level notifications";
      After = [ "graphical-session.target" ];
      PartOf = [ "graphical-session.target" ];
    };
    Service = {
      Type = "simple";
      ExecStart = pkgs.writeShellScript "battery-monitor" ''
      STATE_FILE="/tmp/battery-last-notified"
      echo "100" > "$STATE_FILE"

      while true; do
        CAPACITY=$(cat /sys/class/power_supply/BAT1/capacity 2>/dev/null)
        STATUS=$(cat /sys/class/power_supply/BAT1/status 2>/dev/null)
        LAST=$(cat "$STATE_FILE" 2>/dev/null || echo "100")

        if [[ "$STATUS" == "Discharging" && -n "$CAPACITY" ]]; then
          NOTIFY=false
          if [[ $CAPACITY -le 5 ]]; then
            [[ $CAPACITY -lt $LAST ]] && NOTIFY=true
          else
            for T in 20 15 10; do
              if [[ $CAPACITY -le $T && $LAST -gt $T ]]; then
                NOTIFY=true
                break
              fi
            done
          fi

          if $NOTIFY; then
            URGENCY="normal"
            [[ $CAPACITY -le 5 ]] && URGENCY="critical"
            ${pkgs.libnotify}/bin/notify-send -u "$URGENCY" \
              "Battery Low" "Battery at ''${CAPACITY}%"
            echo "$CAPACITY" > "$STATE_FILE"
          fi
        else
          echo "100" > "$STATE_FILE"
        fi

        sleep 60
      done
    '';
      Restart = "always";
      RestartSec = "10s";
    };
    Install.WantedBy = [ "graphical-session.target" ];
  };
}
