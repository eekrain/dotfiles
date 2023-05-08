{ config, ... }:
{
  services.tlp = {
    enable = true;
    settings = {
      TLP_ENABLE = 1;
      RADEON_DPM_PERF_LEVEL_ON_AC = "high";
      RADEON_DPM_PERF_LEVEL_ON_BAT = "low";
      RADEON_DPM_STATE_ON_AC = "performance";
      RADEON_DPM_STATE_ON_BAT = "battery";
      START_CHARGE_THRESH_BAT0 = 55;
      STOP_CHARGE_THRESH_BAT0 = 60;
      RUNTIME_PM_ON_AC = "on";
      RUNTIME_PM_ON_BAT = "auto";
      DEVICES_TO_DISABLE_ON_LAN_CONNECT = ''"wifi wwan"'';
      DEVICES_TO_DISABLE_ON_WIFI_CONNECT = ''"wwan"'';
      DEVICES_TO_DISABLE_ON_WWAN_CONNECT = ''"wifi"'';
      CPU_SCALING_MIN_FREQ_ON_AC = 400000;
      CPU_SCALING_MAX_FREQ_ON_AC = 4280000;
      CPU_SCALING_MIN_FREQ_ON_BAT = 400000;
      CPU_SCALING_MAX_FREQ_ON_BAT = 4280000;
    };
  };
  services.auto-cpufreq.enable = true;
  # Use the swap partition here
  boot.resumeDevice = "/dev/mapper/main-swap";
}
