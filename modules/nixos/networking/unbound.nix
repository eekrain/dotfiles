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

    environment.etc."resolv.conf" = {
      text = ''
        nameserver 127.0.0.1
        options edns0
      '';
      # Make immutable to prevent ExpressVPN or other services from overwriting
      mode = "0444";
    };

    ##### UNBOUND #####

    services.unbound = {
      enable = true;
      # package = pkgs.unbound.override {
      #   withDoH = true;
      # };

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
              # "174.138.29.175@443#doh.tiar.app"
              "174.138.29.175@853#dot.tiar.app"
            ];
          }
        ];
      };
    };

    ##### TLS CERTS FOR DOT #####

    environment.etc."ssl/certs/ca-certificates.crt".source = "${pkgs.cacert}/etc/ssl/certs/ca-bundle.crt";

    ##### PROTECT RESOLV.CONF FROM VPN OVERRIDES #####

    # Systemd service to restore resolv.conf if VPN (ExpressVPN) overwrites it
    systemd.services.protect-resolv-conf = {
      description = "Protect resolv.conf from VPN overrides";
      wantedBy = ["multi-user.target"];
      after = ["network.target" "unbound.service"];
      serviceConfig = {
        Type = "oneshot";
        RemainAfterExit = true;
        ExecStart = "${pkgs.writeShellScript "protect-resolv-conf" ''
          # Restore resolv.conf to point to local Unbound
          echo "nameserver 127.0.0.1" > /etc/resolv.conf
          echo "options edns0" >> /etc/resolv.conf
          # Make it immutable if not running in a container/sandbox
          if [ -e /usr/bin/chattr ]; then
            chattr +i /etc/resolv.conf 2>/dev/null || true
          fi
        ''}";
      };
    };
  };
}
