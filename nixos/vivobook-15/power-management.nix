{ config, inputs, ... }:
{
  imports = [
    inputs.hardware.nixosModules.common-cpu-amd
    inputs.hardware.nixosModules.common-cpu-amd-pstate
    inputs.hardware.nixosModules.common-pc-laptop
    inputs.hardware.nixosModules.common-pc-laptop-ssd
    inputs.hardware.nixosModules.common-pc-laptop-acpi_call
  ];

  services.auto-cpufreq = {
    enable = true;
    # settings = {
    #   charger = {
    #     governor = "powersave";
    #     turbo = "auto";
    #     energy_performance_preference = "power";
    #   };
    # };
  };

  services.tlp = {
    enable = true;
    settings = {
      START_CHARGE_THRESH_BAT0 = 40;
      STOP_CHARGE_THRESH_BAT0 = 60;
    };
  };

  services = {
    asusd = {
      enable = true;
      enableUserService = true;
    };
    supergfxd.enable = true;
  };

  # Use the swap partition here
  boot.resumeDevice = "/dev/disk/by-label/swap";
}
