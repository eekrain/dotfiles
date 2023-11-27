{ config, inputs, ... }:
{
  disabledModules = [ "nixos/modules/services/hardware/auto-cpufreq.nix" ];
  imports =
    [
      inputs.auto-cpufreq.nixosModules.default
    ];

  services.auto-cpufreq = {
    enable = true;
    settings = {
      battery = {
        governor = "powersave";
        turbo = "never";
        scaling_min_freq = 400000;
        scaling_max_freq = 3210000;
      };
      charger = {
        governor = "powersave";
        turbo = "auto";
        scaling_min_freq = 400000;
        scaling_max_freq = 4280000;
      };
    };
  };

  services.tlp = {
    enable = true;
    settings = {
      START_CHARGE_THRESH_BAT0 = 40;
      STOP_CHARGE_THRESH_BAT0 = 60;
      RADEON_DPM_PERF_LEVEL_ON_AC = "auto";
      RADEON_DPM_PERF_LEVEL_ON_BAT = "auto";
      DEVICES_TO_DISABLE_ON_LAN_CONNECT = ''"wifi wwan"'';
      DEVICES_TO_DISABLE_ON_WIFI_CONNECT = ''"wwan"'';
      DEVICES_TO_DISABLE_ON_WWAN_CONNECT = ''"wifi"'';
    };
  };
  # Use the swap partition here
  boot.resumeDevice = "/dev/mapper/main-swap";
}
