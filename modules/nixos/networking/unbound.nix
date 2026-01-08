{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.myModules.networking;
in {
  options.myModules.networking.unbound =
    lib.mkEnableOption "Enable hardened Unbound DNS resolver";

  config = lib.mkIf cfg.unbound {
    ##### DNS OWNERSHIP #####

    networking.networkmanager.dns = "none";
    services.resolved.enable = lib.mkForce false;
    networking.resolvconf.enable = false;

    networking.enableIPv6 = false;

    networking.nameservers = ["127.0.0.1"];

    environment.etc."resolv.conf".text = ''
      nameserver 127.0.0.1
      options edns0
    '';

    ##### UNBOUND #####

    services.unbound = {
      enable = true;

      settings = {
        server = {
          interface = ["127.0.0.1"];
          port = 53;

          # Access control
          access-control = [
            "127.0.0.0/8 allow"
          ];

          # Protocols
          do-ip4 = "yes";
          do-ip6 = "no";
          do-udp = "yes";
          do-tcp = "yes";

          # Privacy
          hide-identity = "yes";
          hide-version = "yes";
          qname-minimisation = "yes";
          use-caps-for-id = "yes";

          # Hardening
          harden-glue = "yes";
          harden-dnssec-stripped = "yes";
          harden-algo-downgrade = "yes";

          # DNSSEC
          auto-trust-anchor-file = "/var/lib/unbound/root.key";

          # Caching
          prefetch = "yes";
          prefetch-key = "yes";
          cache-min-ttl = 300;
          cache-max-ttl = 86400;
          msg-cache-size = "64m";
          rrset-cache-size = "128m";

          # Reliability
          serve-expired = "yes";
          serve-expired-reply-ttl = 30;
          serve-expired-client-timeout = 1800;
        };

        forward-zone = [
          {
            name = ".";
            forward-tls-upstream = "yes";
            forward-addr = [
              "174.138.29.175@853#dot.tiar.app"
              "1.1.1.1@853#cloudflare-dns.com"
              "1.0.0.1@853#cloudflare-dns.com"
            ];
          }
        ];
      };
    };

    ##### TLS CERTS FOR DOT #####

    environment.etc."ssl/certs/ca-certificates.crt".source = "${pkgs.cacert}/etc/ssl/certs/ca-bundle.crt";
  };
}
