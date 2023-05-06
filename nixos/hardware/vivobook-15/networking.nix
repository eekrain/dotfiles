{ config, ... }:
{
  # Enable networking
  networking.networkmanager.enable = true;
  # Use iwd as networkmanager backend
  networking.networkmanager.wifi.backend = "iwd";

  # Set your time zone.
  time.timeZone = "Asia/Jakarta";
}
