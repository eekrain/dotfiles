{ config, lib, pkgs, ... }:
{
  # Use iwd as networkmanager backend
  # networking.networkmanager.wifi.backend = "iwd";
  services.gnome.gnome-keyring.enable = true;
  # Set your time zone.
  time.timeZone = "Asia/Jakarta";
  services.ntp.enable = true;
  programs.ssh.startAgent = true;

  networking.extraHosts =
    ''
      127.0.0.1 mydomain.com
      127.0.0.1 dashboard.mydomain.com
    '';


  networking.firewall = {
    enable = false;
    # allowedTCPPortRanges = [
    #   { from = 0; to = 65535; }
    # ];
    # allowedUDPPortRanges = [
    #   { from = 0; to = 65535; }
    # ];
  };

  networking = {
    networkmanager.enable = true;
  };
}
