{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.myModules.networking;
in {
  options.myModules.networking.dnscrypt = lib.mkEnableOption "Enable dnscrypt-proxy2 with pengelana/blocklist";

  config = lib.mkIf cfg.dnscrypt {
    # Configure dnscrypt-proxy2 with pengelana/blocklist settings
    services.dnscrypt-proxy2 = {
      enable = true;

      settings = {
        # Server configuration from pengelana/blocklist
        server_names = ["doh.tiar.app" "doh.tiar.app-doh" "doh.tiar.app-ipv6" "doh.tiar.app-doh-ipv6"];

        # Listen addresses
        listen_addresses = ["127.0.0.1:53" "[::1]:53"];

        # Maximum number of simultaneous client connections
        max_clients = 250;

        # Server requirements
        ipv4_servers = true;
        ipv6_servers = false;
        dnscrypt_servers = true;
        doh_servers = true;

        # Require servers to satisfy specific properties
        require_dnssec = false;
        require_nolog = true;
        require_nofilter = true;

        # Disabled server names
        disabled_server_names = [];

        # Network settings
        force_tcp = false;
        timeout = 2500;
        keepalive = 30;

        # Response settings
        refused_code_in_responses = false;

        # Certificate refresh
        cert_refresh_delay = 240;

        # Fallback resolver (bootstrap_resolvers in NixOS module)
        # fallback_resolver option is not supported, using bootstrap_resolvers instead
        ignore_system_dns = false;

        # Network probe settings
        netprobe_timeout = 60;
        netprobe_address = "9.9.9.9:53";

        # Log files rotation
        log_files_max_size = 10;
        log_files_max_age = 7;
        log_files_max_backups = 1;

        # Filters
        block_ipv6 = false;

        # DNS cache
        cache = true;
        cache_size = 512;
        cache_min_ttl = 600;
        cache_max_ttl = 86400;
        cache_neg_min_ttl = 60;
        cache_neg_max_ttl = 600;

        # Query logging
        query_log.format = "tsv";

        # Suspicious queries logging
        nx_log.format = "tsv";

        # Remote lists of available servers
        sources = {
          "public-resolvers" = {
            urls = [
              "https://raw.githubusercontent.com/DNSCrypt/dnscrypt-resolvers/master/v2/public-resolvers.md"
              "https://download.dnscrypt.info/resolvers-list/v2/public-resolvers.md"
            ];
            cache_file = "public-resolvers.md";
            minisign_key = "RWQf6LRCGA9i53mlYecO4IzT51TGPpvWucNSCh1CBM0QTaLn73Y7GFO3";
            prefix = "";
          };
        };
      };
    };

    # Set StateDirectory for systemd service
    systemd.services.dnscrypt-proxy2.serviceConfig.StateDirectory = "dnscrypt-proxy";

    # Ensure systemd-resolved is disabled
    services.resolved.enable = lib.mkForce false;

    # Set DNS nameservers to localhost
    networking.nameservers = ["127.0.0.1" "::1"];

    # Prevent NetworkManager from overriding DNS
    networking.networkmanager.dns = "none";
  };
}
