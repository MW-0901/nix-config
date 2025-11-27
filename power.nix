{ config, pkgs, lib, ... }:

{
  # Power management
  powerManagement = {
    enable = true;
    powertop.enable = true;
    cpuFreqGovernor = "powersave";
  };

  # TLP for advanced power management
  services.tlp = {
    enable = true;
    settings = {
      # CPU
      CPU_SCALING_GOVERNOR_ON_AC = "performance";
      CPU_SCALING_GOVERNOR_ON_BAT = "powersave";
      CPU_ENERGY_PERF_POLICY_ON_AC = "balance_performance";
      CPU_ENERGY_PERF_POLICY_ON_BAT = "power";
      CPU_BOOST_ON_AC = 1;
      CPU_BOOST_ON_BAT = 0;
      
      # Platform
      PLATFORM_PROFILE_ON_AC = "performance";
      PLATFORM_PROFILE_ON_BAT = "low-power";
      
      # GPU
      INTEL_GPU_MIN_FREQ_ON_BAT = 300;
      INTEL_GPU_MAX_FREQ_ON_BAT = 800;
      
      # Radio
      WIFI_PWR_ON_BAT = "on";
      
      # USB (exclude YubiKey)
      USB_AUTOSUSPEND = 1;
      USB_DENYLIST = "1050:0407";
      
      # Battery care
      START_CHARGE_THRESH_BAT0 = 75;
      STOP_CHARGE_THRESH_BAT0 = 80;
    };
  };

  # Thermal management
  services.thermald.enable = true;

  # Kernel parameters
  boot.kernelParams = [
    "intel_pstate=active"
    "i915.enable_psr=2"
    "nmi_watchdog=0"
  ];

  boot.kernel.sysctl = {
    "vm.dirty_writeback_centisecs" = 1500;
  };
}
