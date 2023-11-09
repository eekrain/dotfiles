{ config, lib, ... }:
{
  # Enable networking
  networking.networkmanager.enable = true;
  # Use iwd as networkmanager backend
  # networking.networkmanager.wifi.backend = "iwd";
  services.gnome.gnome-keyring.enable = true;

  # Set your time zone.
  time.timeZone = "Asia/Makassar";

  services.ntp.enable = true;

  networking.extraHosts =
    ''
      127.0.0.1 mydomain.com
      127.0.0.1 dashboard.mydomain.com
    '';

  networking.firewall = {
    enable = true;
    allowedTCPPortRanges = [
      { from = 0; to = 65535; }
    ];
    allowedUDPPortRanges = [
      { from = 0; to = 65535; }
    ];
  };

  programs.ssh.startAgent = true;
}
