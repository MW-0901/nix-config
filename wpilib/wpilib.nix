{ config, pkgs, lib, ... }:

let
  wpilibLauncher = pkgs.writeShellScriptBin "wpilib-code" ''
    cd ${config.users.users.mark.home}/config/wpilib
    ${pkgs.docker-compose}/bin/docker-compose up -d
    
    ${pkgs.docker}/bin/docker exec frc-dev \
      /home/mark/wpilib/2026/vscode/VSCode-linux-x64/bin/code \
      --user-data-dir=/home/mark/.wpilib/2026/vscode "$@" >/dev/null 2>&1 &
    
    disown
  '';

  wpilibShell = pkgs.writeShellScriptBin "wpilib-shell" ''
    #!/usr/bin/env bash
    
    cd ${config.users.users.mark.home}/config/wpilib
    ${pkgs.docker-compose}/bin/docker-compose up -d
    
    ${pkgs.docker}/bin/docker exec -it frc-dev bash "$@"
  '';

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

  stateDir = "/var/lib/wpilib-setup";
  reminderFile = "${stateDir}/installer-reminder-shown";

in {
  virtualisation.docker.enable = true;
  users.users.mark.extraGroups = [ "docker" ];

  environment.systemPackages = [
    wpilibLauncher
    wpilibShell
    wpilibDesktop
  ];

  environment.pathsToLink = [ "/share/applications" ];

  systemd.tmpfiles.rules = [
    "d ${stateDir} 0755 root root -"
  ];

  system.activationScripts.wpilibReminder = lib.stringAfter [ "users" ] ''
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
