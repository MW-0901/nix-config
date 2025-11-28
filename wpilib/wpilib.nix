{ config, pkgs, lib, ... }:

let
  homeDir = config.users.users.mark.home;
  wpilibDir = "${homeDir}/wpilib/2026";
  
  # Define all WPILib tools with their executables and icons
  wpilibTools = {
    advantagescope = {
      name = "AdvantageScope";
      exec = "${wpilibDir}/advantagescope/advantagescope-wpilib";
      icon = "${wpilibDir}/icons/advantagescope.png";
      comment = "Log visualization and analysis tool";
    };
    glass = {
      name = "Glass";
      exec = "${wpilibDir}/tools/glass";
      icon = "${wpilibDir}/icons/glass.png";
      comment = "Dashboard and field view";
    };
    outlineviewer = {
      name = "OutlineViewer";
      exec = "${wpilibDir}/tools/outlineviewer";
      icon = "${wpilibDir}/icons/outlineviewer.png";
      comment = "NetworkTables viewer";
    };
    shuffleboard = {
      name = "Shuffleboard";
      exec = "${wpilibDir}/tools/Shuffleboard";
      icon = "${wpilibDir}/icons/glass.png"; # Shuffleboard uses glass icon
      comment = "Modern dashboard for FRC";
    };
    smartdashboard = {
      name = "SmartDashboard";
      exec = "${wpilibDir}/tools/SmartDashboard";
      icon = "${wpilibDir}/icons/glass.png";
      comment = "Classic FRC dashboard";
    };
    pathweaver = {
      name = "PathWeaver";
      exec = "${wpilibDir}/tools/PathWeaver";
      icon = "${wpilibDir}/icons/glass.png";
      comment = "Path planning tool";
    };
    robotbuilder = {
      name = "RobotBuilder";
      exec = "${wpilibDir}/tools/RobotBuilder";
      icon = "${wpilibDir}/icons/robotbuilder.png";
      comment = "Visual robot code builder";
    };
    sysid = {
      name = "SysId";
      exec = "${wpilibDir}/tools/sysid";
      icon = "${wpilibDir}/icons/sysid.png";
      comment = "System identification tool";
    };
    datalogtool = {
      name = "DataLogTool";
      exec = "${wpilibDir}/tools/datalogtool";
      icon = "${wpilibDir}/icons/datalogtool.png";
      comment = "Data log viewer";
    };
    roborioTeamNumberSetter = {
      name = "roboRIO Team Number Setter";
      exec = "${wpilibDir}/tools/roborioteamnumbersetter";
      icon = "${wpilibDir}/icons/roborioteamnumbersetter.png";
      comment = "Set team number on roboRIO";
    };
    elastic = {
      name = "Elastic";
      exec = "${wpilibDir}/elastic/elastic_dashboard";
      icon = "${wpilibDir}/icons/elastic.png";
      comment = "Elastic Dashboard";
    };
  };

  # Function to create a launcher script for a tool
  mkToolLauncher = name: tool: pkgs.writeShellScriptBin "wpilib-${name}" ''
    #!/usr/bin/env bash
    
    # Ensure container is running
    cd ${homeDir}/config/wpilib
    ${pkgs.docker-compose}/bin/docker-compose up -d
    
    # Launch tool in background and fully detach
    ${pkgs.docker}/bin/docker exec frc-dev ${tool.exec} "$@" >/dev/null 2>&1 &
    
    disown
  '';

  # Function to create a desktop entry for a tool
  mkToolDesktop = name: tool: pkgs.makeDesktopItem {
    name = "wpilib-${name}";
    desktopName = "WPILib ${tool.name}";
    comment = tool.comment;
    exec = "${mkToolLauncher name tool}/bin/wpilib-${name} %F";
    icon = tool.icon;
    terminal = false;
    type = "Application";
    categories = [ "Development" ];
  };

  # VS Code launcher (special case)
  wpilibCode = pkgs.writeShellScriptBin "wpilib-code" ''
    #!/usr/bin/env bash
    
    # Ensure container is running
    cd ${homeDir}/config/wpilib
    ${pkgs.docker-compose}/bin/docker-compose up -d
    
    # Launch VS Code in background and fully detach
    ${pkgs.docker}/bin/docker exec frc-dev \
      ${homeDir}/wpilib/2026/vscode/VSCode-linux-x64/bin/code \
      --user-data-dir=${homeDir}/.wpilib/2026/vscode "$@" >/dev/null 2>&1 &
    
    disown
  '';

  # VS Code desktop entry
  wpilibCodeDesktop = pkgs.makeDesktopItem {
    name = "wpilib-vscode";
    desktopName = "WPILib VS Code";
    comment = "WPILib Development Environment";
    exec = "${wpilibCode}/bin/wpilib-code %F";
    icon = "${wpilibDir}/icons/wpilib-icon-256.png";
    terminal = false;
    type = "Application";
    categories = [ "Development" "IDE" ];
    mimeTypes = [ "text/plain" "inode/directory" ];
  };

  # Shell launcher
  wpilibShell = pkgs.writeShellScriptBin "wpilib-shell" ''
    #!/usr/bin/env bash
    
    # Ensure container is running
    cd ${homeDir}/config/wpilib
    ${pkgs.docker-compose}/bin/docker-compose up -d
    
    # Launch interactive shell in container
    ${pkgs.docker}/bin/docker exec -it frc-dev bash "$@"
  '';

  # Generate all tool launchers and desktop entries
  allToolLaunchers = lib.mapAttrsToList mkToolLauncher wpilibTools;
  allToolDesktops = lib.mapAttrsToList mkToolDesktop wpilibTools;

  # State file to track if reminder has been shown
  stateDir = "/var/lib/wpilib-setup";
  reminderFile = "${stateDir}/installer-reminder-shown";

in {
  # Enable Docker
  virtualisation.docker.enable = true;
  users.users.mark.extraGroups = [ "docker" ];

  # Install all launchers and desktop entries
  environment.systemPackages = [
    wpilibCode
    wpilibCodeDesktop
    wpilibShell
  ] ++ allToolLaunchers ++ allToolDesktops;

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
    ║  Available commands:                                                   ║
    ║    - wpilib-code              (VS Code)                                ║
    ║    - wpilib-shell             (Development shell)                      ║
    ║    - wpilib-advantagescope    (Log viewer)                             ║
    ║    - wpilib-glass             (Dashboard)                              ║
    ║    - wpilib-shuffleboard      (Modern dashboard)                       ║
    ║    - wpilib-outlineviewer     (NetworkTables)                          ║
    ║    - wpilib-sysid             (System ID)                              ║
    ║    - wpilib-pathweaver        (Path planning)                          ║
    ║    - wpilib-robotbuilder      (Visual builder)                         ║
    ║    - wpilib-datalogtool       (Data logs)                              ║
    ║    - wpilib-elastic           (Elastic dashboard)                      ║
    ║                                                                        ║
    ╚════════════════════════════════════════════════════════════════════════╝
    
    EOF
      touch "${reminderFile}"
    fi
  '';
}
