{ config, lib, ... }:
{
  # Enable networking
  networking.networkmanager.enable = true;
  # Use iwd as networkmanager backend
  # networking.networkmanager.wifi.backend = "iwd";
  services.gnome.gnome-keyring.enable = true;

  # Set your time zone.
  time.timeZone = "Asia/Makassar";

  networking.extraHosts =
    ''
      127.0.0.1 mydomain.com
      127.0.0.1 dashboard.mydomain.com
    '';

  specialisation = {
    proxied_hotspot.configuration = {
      boot.loader.grub.configurationName = lib.mkForce "Proxied Hotspot";
      networking.proxy.default = "http://169.254.1.1:10809";
      networking.proxy.httpProxy = "http://169.254.1.1:10809";
      networking.proxy.httpsProxy = "http://169.254.1.1:10809";
      networking.proxy.ftpProxy = "http://169.254.1.1:10809";
      networking.proxy.rsyncProxy = "http://169.254.1.1:10809";
      networking.proxy.allProxy = "http://169.254.1.1:10809";
      networking.proxy.noProxy = "127.0.0.1,localhost,work.com";

      environment.sessionVariables = {
        HTTPS_PROXY = "http://169.254.1.1:10809";
        HTTP_PROXY = "http://169.254.1.1:10809";
      };
    };
  };

  services.dnscrypt-proxy2 = {
    enable = true;
    # configFile = ./dnscrypt-tiarap.toml;
  };

  systemd.services.dnscrypt-proxy2.serviceConfig = {
    StateDirectory = "dnscrypt-proxy";
  };

  networking.firewall = {
    enable = false;
    allowedTCPPorts = [ 80 443 ];
    allowedTCPPortRanges = [
      { from = 3000; to = 3010; }
      { from = 8080; to = 8090; }
    ];
  };
}
