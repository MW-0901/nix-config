{
  config,
  pkgs,
  lib,
  ...
}:

{
  services.power-profiles-daemon.enable = lib.mkForce false;

  powerManagement = {
    enable = true;
    powertop.enable = true;
    cpuFreqGovernor = "powersave";
  };

  services.tlp = {
    enable = true;
    settings = {

      CPU_SCALING_GOVERNOR_ON_AC = "performance";
      CPU_SCALING_GOVERNOR_ON_BAT = "powersave";
      CPU_ENERGY_PERF_POLICY_ON_AC = "balance_performance";
      CPU_ENERGY_PERF_POLICY_ON_BAT = "power";
      CPU_BOOST_ON_AC = 1;
      CPU_BOOST_ON_BAT = 0;

      CPU_MIN_PERF_ON_AC = 0;
      CPU_MAX_PERF_ON_AC = 100;
      CPU_MIN_PERF_ON_BAT = 0;
      CPU_MAX_PERF_ON_BAT = 30;

      PLATFORM_PROFILE_ON_AC = "performance";
      PLATFORM_PROFILE_ON_BAT = "low-power";

      INTEL_GPU_MIN_FREQ_ON_AC = 300;
      INTEL_GPU_MAX_FREQ_ON_AC = 2250;
      INTEL_GPU_MIN_FREQ_ON_BAT = 300;
      INTEL_GPU_MAX_FREQ_ON_BAT = 800;
      INTEL_GPU_BOOST_FREQ_ON_AC = 2250;
      INTEL_GPU_BOOST_FREQ_ON_BAT = 800;

      WIFI_PWR_ON_AC = "off";
      WIFI_PWR_ON_BAT = "off";
      WOL_DISABLE = "Y";

      SOUND_POWER_SAVE_ON_AC = 0;
      SOUND_POWER_SAVE_ON_BAT = 1;
      SOUND_POWER_SAVE_CONTROLLER = "Y";

      PCIE_ASPM_ON_AC = "default";
      PCIE_ASPM_ON_BAT = "powersupersave";

      RUNTIME_PM_ON_AC = "on";
      RUNTIME_PM_ON_BAT = "auto";

      USB_AUTOSUSPEND = 1;
      USB_DENYLIST = "1050:0407";
      USB_EXCLUDE_AUDIO = 1;
      USB_EXCLUDE_BTUSB = 0;
      USB_EXCLUDE_PHONE = 0;
      USB_EXCLUDE_PRINTER = 1;
      USB_EXCLUDE_WWAN = 0;

      START_CHARGE_THRESH_BAT0 = 75;
      STOP_CHARGE_THRESH_BAT0 = 80;

      DISK_IDLE_SECS_ON_AC = 0;
      DISK_IDLE_SECS_ON_BAT = 2;

      SATA_LINKPWR_ON_AC = "med_power_with_dipm";
      SATA_LINKPWR_ON_BAT = "med_power_with_dipm";

      AHCI_RUNTIME_PM_ON_AC = "on";
      AHCI_RUNTIME_PM_ON_BAT = "auto";
      AHCI_RUNTIME_PM_TIMEOUT = 15;
    };
  };

  services.thermald.enable = true;

  boot.kernelParams = [

    "intel_pstate=active"

    "i915.enable_psr=2"

    "i915.enable_fbc=1"

    "nmi_watchdog=0"

    "i915.enable_rc6=1"

    "i915.enable_dc=2"

  ];

  boot.kernel.sysctl = {

    "vm.dirty_writeback_centisecs" = 6000;
    "vm.dirty_expire_centisecs" = 3000;
    "vm.dirty_ratio" = 10;
    "vm.dirty_background_ratio" = 5;

    "vm.swappiness" = 10;

    "net.core.default_qdisc" = "fq_codel";
  };

  services.upower = {
    enable = true;
    percentageLow = 15;
    percentageCritical = 5;
    percentageAction = 3;
    criticalPowerAction = "Hibernate";
  };

  boot.kernelModules = [ "laptop_mode" ];

  services.fwupd.enable = true;
}
