{
  config,
  pkgs,
  lib,
  ...
}:

{

  services.power-profiles-daemon.enable = lib.mkForce false;

  services.tlp.enable = true;
  services.tlp.settings = {

    CPU_SCALING_GOVERNOR_ON_AC = "performance";
    CPU_SCALING_GOVERNOR_ON_BAT = "powersave";

    CPU_MIN_PERF_ON_AC = 0;
    CPU_MAX_PERF_ON_AC = 100;
    CPU_BOOST_ON_AC = 1;
    CPU_ENERGY_PERF_POLICY_ON_AC = "performance";

    CPU_MIN_PERF_ON_BAT = 0;
    CPU_MAX_PERF_ON_BAT = 5;
    CPU_BOOST_ON_BAT = 0;
    CPU_ENERGY_PERF_POLICY_ON_BAT = "power";

    CPU_HWP_DYN_BOOST_ON_AC = 1;
    CPU_HWP_DYN_BOOST_ON_BAT = 0;

    PLATFORM_PROFILE_ON_AC = "performance";
    PLATFORM_PROFILE_ON_BAT = "low-power";

    INTEL_GPU_MIN_FREQ_ON_AC = 300;
    INTEL_GPU_MAX_FREQ_ON_AC = 2250;
    INTEL_GPU_BOOST_FREQ_ON_AC = 2250;

    INTEL_GPU_MIN_FREQ_ON_BAT = 300;
    INTEL_GPU_MAX_FREQ_ON_BAT = 800;
    INTEL_GPU_BOOST_FREQ_ON_BAT = 0;

    WIFI_PWR_ON_AC = "off";
    WIFI_PWR_ON_BAT = "on";

    USB_AUTOSUSPEND = 1;
    PCIE_ASPM_ON_AC = "default";
    PCIE_ASPM_ON_BAT = "powersupersave";

    SATA_LINKPWR_ON_AC = "med_power_with_dipm";
    SATA_LINKPWR_ON_BAT = "med_power_with_dipm";

    AHCI_RUNTIME_PM_ON_AC = "on";
    AHCI_RUNTIME_PM_ON_BAT = "auto";
    AHCI_RUNTIME_PM_TIMEOUT = 15;

    START_CHARGE_THRESH_BAT0 = 75;
    STOP_CHARGE_THRESH_BAT0 = 80;

    SOUND_POWER_SAVE_ON_AC = 0;
    SOUND_POWER_SAVE_ON_BAT = 1;
    SOUND_POWER_SAVE_CONTROLLER = "Y";
  };

  services.thermald.enable = true;

  boot.kernelParams = [
    "intel_pstate=active"
    "intel_pstate=disable_hwp"
    "i915.enable_psr=2"
    "i915.enable_fbc=1"
    "i915.enable_rc6=1"
    "i915.enable_dc=2"
    "nmi_watchdog=0"
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

  powerManagement.enable = true;
  powerManagement.powertop.enable = true;
}
