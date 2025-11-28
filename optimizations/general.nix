{ config, pkgs, ... }:

{
  # Optimize Nix daemon
  nix.daemonCPUSchedPolicy = "idle";
  nix.daemonIOSchedClass = "idle";
  # Systemd optimizations
  systemd = {
    # User service optimizations
    user.extraConfig = ''
      DefaultTimeoutStopSec=10s
      DefaultTimeoutStartSec=10s
    '';
  };

  fileSystems."/".options = [
    "noatime"
    "nodiratime"
    "commit=60"
  ];

  zramSwap = {
    enable = true;
    algorithm = "zstd";
    memoryPercent = 50;
  };

  services.earlyoom = {
    enable = true;
    freeMemThreshold = 5;
    freeSwapThreshold = 10;
    enableNotifications = true;
  };

  systemd.tmpfiles.rules = [
    "d /tmp 1777 root root 3d"
    "d /var/tmp 1777 root root 7d"
  ];

  fonts.fontconfig.cache32Bit = false;

  programs.kdeconnect.enable = false;

  networking = {
    firewall.enable = true;

    networkmanager.dns = "systemd-resolved";
  };

  services.resolved = {
    enable = true;
    dnssec = "allow-downgrade";
    dnsovertls = "opportunistic";
    fallbackDns = [
      "1.1.1.1"
      "8.8.8.8"
    ];
  };

  services.journald.extraConfig = ''
    SystemMaxUse=500M
    RuntimeMaxUse=100M
    SystemMaxFileSize=50M
  '';
}
