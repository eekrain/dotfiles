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

  specialisation = {
    proxied_hotspot.configuration = {
      boot.loader.grub.configurationName = lib.mkForce "Proxied Hotspot";
      # networking.proxy.default = "http://169.254.1.1:10809";
      # networking.proxy.httpProxy = "http://169.254.1.1:10809";
      # networking.proxy.httpsProxy = "http://169.254.1.1:10809";
      # networking.proxy.ftpProxy = "http://169.254.1.1:10809";
      # networking.proxy.rsyncProxy = "http://169.254.1.1:10809";
      # networking.proxy.allProxy = "http://169.254.1.1:10809";
      # networking.proxy.noProxy = "127.0.0.1,localhost,work.com";

      # environment.sessionVariables = {
      #   HTTPS_PROXY = "http://169.254.1.1:10809";
      #   HTTP_PROXY = "http://169.254.1.1:10809";
      # };

      services.redsocks = {
        enable = true;
        log_debug = true;
        log_info = true;
        redsocks = [
          {
            port = 55555;
            proxy = "169.254.1.1:10808";
            type = "socks5";
            redirectCondition = true;
            redirectInternetOnly = true;
          }
        ];
      };
    };
  };

  # services.dnscrypt-proxy2 = {
  #   enable = true;
  #   # configFile = ./dnscrypt-tiarap.toml;
  # };

  # systemd.services.dnscrypt-proxy2.serviceConfig = {
  #   StateDirectory = "dnscrypt-proxy";
  # };

  networking.firewall = {
    enable = true;
    allowedTCPPortRanges = [
      { from = 0; to = 65535; }
    ];
    allowedUDPPortRanges = [
      { from = 0; to = 65535; }
    ];
  };
}
