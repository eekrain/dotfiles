{ config, lib, ... }:
{
  # Use iwd as networkmanager backend
  # networking.networkmanager.wifi.backend = "iwd";
  services.gnome.gnome-keyring.enable = true;

  # Set your time zone.
  time.timeZone = "Asia/Makassar";
  services.ntp.enable = true;
  programs.ssh.startAgent = true;

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

  networking = {
    networkmanager.enable = true;
    nameservers = [ "127.0.0.1" "::1" ];
    networkmanager.dns = "none";
  };

  services = {
    resolved.enable = lib.mkForce false;
    dnscrypt-proxy2 = {
      enable = true;
      upstreamDefaults = true;
      settings = {
        # - To a faster startup when configuring this file
        # - You can choose a specific set of servers from https://github.com/DNSCrypt/dnscrypt-resolvers/blob/master/v3/public-resolvers.md
        server_names = [ "doh.tiar.app" "doh.tiar.app-doh" ];

        ipv4_servers = true;
        ipv6_servers = false;
        dnscrypt_servers = true;
        doh_servers = true;

        require_dnssec = true;
        require_nolog = true;
        require_nofilter = true;
        block_ipv6 = true;

        # Load-balancing: top 2, update ping over time
        lb_strategy = "p2";
        lb_estimator = true;

        # Cache
        # https://00f.net/2019/11/03/stop-using-low-dns-ttls/
        cache = true;
        cache_size = 8192;
        cache_min_ttl = 86400; # 1 day
        cache_max_ttl = 86400; # 1 day
        #cache_max_ttl = 604800; # 7 days
        cache_neg_min_ttl = 60; # 1 min
        cache_neg_max_ttl = 600; # 10 min
      };
    };
  };
}
