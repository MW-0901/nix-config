{
  pkgs,
  ...
}:

{

  networking.firewall = {
    allowPing = false;
    logReversePathDrops = true;
    logRefusedConnections = false;
  };
  services.clamav.daemon.enable = true;
  services.logrotate.enable = true;
  services.clamav.updater.enable = true;
  boot.kernelParams = [

    "debugfs=off"

    "pti=on"

    "sysrq_always_enabled=0"

    "randomize_kstack_offset=on"
  ];

  boot.kernel.sysctl = {

    "net.ipv4.conf.all.rp_filter" = 1;
    "net.ipv4.conf.default.rp_filter" = 1;
    "net.ipv4.conf.all.accept_source_route" = 0;
    "net.ipv4.conf.default.accept_source_route" = 0;
    "net.ipv6.conf.all.accept_source_route" = 0;
    "net.ipv6.conf.default.accept_source_route" = 0;
    "net.ipv4.conf.all.send_redirects" = 0;
    "net.ipv4.conf.default.send_redirects" = 0;
    "net.ipv4.conf.all.accept_redirects" = 0;
    "net.ipv4.conf.default.accept_redirects" = 0;
    "net.ipv6.conf.all.accept_redirects" = 0;
    "net.ipv6.conf.default.accept_redirects" = 0;
    "net.ipv4.icmp_echo_ignore_all" = 1;
    "net.ipv4.tcp_syncookies" = 1;
    "net.ipv4.conf.all.log_martians" = 1;
    "net.ipv4.conf.default.log_martians" = 1;
    "net.core.bpf_jit_harden" = 2;

    "kernel.dmesg_restrict" = 1;
    "kernel.kptr_restrict" = 2;
    "kernel.unprivileged_bpf_disabled" = 1;
    "kernel.unprivileged_userns_clone" = 0;
    "kernel.yama.ptrace_scope" = 2;
    "kernel.sysrq" = 0;
    "dev.tty.ldisc_autoload" = 0;

    "fs.protected_hardlinks" = 1;
    "fs.protected_symlinks" = 1;
    "fs.protected_fifos" = 2;
    "fs.protected_regular" = 2;
    "fs.suid_dumpable" = 0;
  };

  security.apparmor = {
    enable = true;
    packages = [ pkgs.apparmor-profiles ];
    killUnconfinedConfinables = true;
  };

  security.sudo = {
    enable = true;
    execWheelOnly = true;
    extraConfig = ''
      Defaults timestamp_timeout=5
      Defaults lecture="never"
    '';
  };

  security.pam.loginLimits = [
    {
      domain = "*";
      type = "hard";
      item = "core";
      value = "0";
    }
    {
      domain = "*";
      type = "hard";
      item = "nofile";
      value = "1048576";
    }
    {
      domain = "*";
      type = "hard";
      item = "nproc";
      value = "4096";
    }
  ];

  systemd.coredump.enable = false;

  boot.specialFileSystems = {
    "/proc".options = [ "hidepid=2" ];
  };

  boot.blacklistedKernelModules = [

    "dccp"
    "sctp"
    "rds"
    "tipc"

    "cramfs"
    "freevxfs"
    "jffs2"
    "hfs"
    "hfsplus"
    "udf"

  ];

  security.auditd.enable = true;
  security.audit.enable = true;
  security.audit.rules = [

    "-w /etc/passwd -p wa -k identity"
    "-w /etc/group -p wa -k identity"
    "-w /etc/shadow -p wa -k identity"
    "-w /etc/sudoers -p wa -k sudoers"

    "-a always,exit -F arch=b64 -S execve -k exec"
    "-a always,exit -F arch=b64 -S adjtimex -S settimeofday -k time"

    "-a always,exit -F arch=b64 -S socket -S connect -k network"
  ];

  services.openssh.enable = false;
}
