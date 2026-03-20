{ pkgs, ... }:
{
  programs.tmux = {
    enable = true;
    terminal = "tmux-256color";
    historyLimit = 50000;
    keyMode = "vi";
    escapeTime = 10;
    sensibleOnTop = true;

    extraConfig = ''
set -g base-index 1
setw -g pane-base-index 1
set -g renumber-windows on
set -g focus-events on
set -ga terminal-overrides ",xterm-256color:Tc"

set -g status on
set -g status-interval 5
set -g status-position bottom

set -g status-style "fg=white,bg=black"

set -g status-left-length 30
set -g status-left "#[fg=cyan,bold][#S]#[default] "

set -g status-justify left
setw -g window-status-format         " #I:#W "
setw -g window-status-current-format "#[fg=black,bg=cyan,bold] #I:#W #[default]"

set -g status-right-length 100
set -g status-right "\
 BAT: #{battery_percentage} #{battery_status_text}\
 | MEM: #(free -m | awk 'NR==2{print $3\"MB\"}')\
 | CPU: #{cpu_percentage}\
 | DISK: #(df -BG / | awk 'NR==2{print $3}')\
 | %Y-%m-%d %H:%M "

set -g pane-border-style        "fg=colour238"
set -g pane-active-border-style "fg=cyan"

run-shell ${pkgs.tmuxPlugins.cpu}/share/tmux-plugins/cpu/cpu.tmux
run-shell ${pkgs.tmuxPlugins.battery}/share/tmux-plugins/battery/battery.tmux
    '';
  };
}
