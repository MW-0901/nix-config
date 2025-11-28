{ config, pkgs, lib, ... }:

let
  # Launcher script that properly passes display and cursor settings
  wpilibLauncher = pkgs.writeShellScriptBin "wpilib-code" ''
    #!/usr/bin/env bash
    
    # Ensure container is running
    cd ${config.users.users.mark.home}/config/wpilib
    ${pkgs.docker-compose}/bin/docker-compose up -d
    
    # Launch VS Code in background and fully detach
    ${pkgs.docker}/bin/docker exec frc-dev \
      /home/mark/wpilib/2026/vscode/VSCode-linux-x64/bin/code \
      --user-data-dir=/home/mark/.wpilib/2026/vscode "$@" >/dev/null 2>&1 &
    
    disown
  '';

  # Shell launcher for interactive development
  wpilibShell = pkgs.writeShellScriptBin "wpilib-shell" ''
    #!/usr/bin/env bash
    
    # Ensure container is running
    cd ${config.users.users.mark.home}/config/wpilib
    ${pkgs.docker-compose}/bin/docker-compose up -d
    
    # Launch interactive shell in container
    ${pkgs.docker}/bin/docker exec -it frc-dev bash "$@"
  '';

  # Desktop entry for KDE/Plasma
  wpilibDesktop = pkgs.makeDesktopItem {
    name = "wpilib-vscode";
    desktopName = "WPILib VS Code";
    comment = "WPILib Development Environment";
    exec = "${wpilibLauncher}/bin/wpilib-code %F";
    icon = "${config.users.users.mark.home}/wpilib/2026/icons/wpilib-icon-256.png";
    terminal = false;
    type = "Application";
    categories = [ "Development" "IDE" ];
    mimeTypes = [ "text/plain" "inode/directory" ];
  };

  # State file to track if reminder has been shown
  stateDir = "/var/lib/wpilib-setup";
  reminderFile = "${stateDir}/installer-reminder-shown";

in {
  # Enable Docker
  virtualisation.docker.enable = true;
  users.users.mark.extraGroups = [ "docker" ];

  # Install the launcher script and desktop entry
  environment.systemPackages = [
    wpilibLauncher
    wpilibShell
    wpilibDesktop
  ];

  # Ensure XDG desktop entries are updated
  environment.pathsToLink = [ "/share/applications" ];

  # Create state directory for tracking reminders
  systemd.tmpfiles.rules = [
    "d ${stateDir} 0755 root root -"
  ];

  # One-time reminder to install WPILib
  system.activationScripts.wpilibReminder = lib.stringAfter [ "users" ] ''
    # Ensure state directory exists
    mkdir -p "${stateDir}"
    
    if [ ! -f "${reminderFile}" ]; then
      cat << 'EOF'
    
    ╔════════════════════════════════════════════════════════════════════════╗
    ║                    WPILib Setup Reminder                               ║
    ╠════════════════════════════════════════════════════════════════════════╣
    ║                                                                        ║
    ║  You need to install WPILib inside the Docker container:               ║
    ║                                                                        ║
    ║  1. Start a shell in the container:                                    ║
    ║     $ wpilib-shell                                                     ║
    ║                                                                        ║
    ║  2. Run the WPILib installer:                                          ║
    ║     $ /wpilib/*/WPILibInstaller                                        ║
    ║                                                                        ║
    ║  3. After installation, silence the warning:                           ║
    ║     $ SILENCE_WPILIB_WARNING                                           ║
    ║                                                                        ║
    ║  After setup, use:                                                     ║
    ║    - wpilib-code     (launch VS Code)                                  ║
    ║    - wpilib-shell    (open development shell)                          ║
    ║                                                                        ║
    ╚════════════════════════════════════════════════════════════════════════╝
    
    EOF
      touch "${reminderFile}"
    fi
  '';
}
