{ config, lib, ... }:
{
  # Enable networking
  networking.networkmanager.enable = true;
  # Use iwd as networkmanager backend
  networking.networkmanager.wifi.backend = "iwd";

  # Set your time zone.
  time.timeZone = "Asia/Jakarta";

  specialisation = {
    proxied_hotspot.configuration = {
      boot.loader.grub.configurationName = lib.mkForce "Proxied Hotspot";
      networking.proxy.default = "http://172.19.0.1:8080";
      networking.proxy.noProxy = "127.0.0.1,localhost,work.com";
    };
  };

}
