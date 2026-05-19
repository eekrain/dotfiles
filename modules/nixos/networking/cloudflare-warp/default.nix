{
  config,
  lib,
  pkgs,
  ...
}:
with lib; let
  cfg = config.myModules.networking;
in {
  meta.maintainers = with maintainers; [wolfangaukang];

  options.myModules.networking.cloudflare-warp = mkEnableOption (lib.mdDoc "cloudflare-warp, a service that replaces the connection between your device and the Internet with a modern, optimized, protocol");

  config = mkIf cfg.cloudflare-warp {
    environment.systemPackages = [
      pkgs.cloudflare-warp # for warp-svc
      (pkgs.writeShellApplication {
        name = "warp-full";
        runtimeInputs = [
          pkgs.cloudflare-warp
          pkgs.coreutils
          pkgs.e2fsprogs
          pkgs.systemd
        ];
        text = ''
          set -euo pipefail

          resolv_conf=/etc/resolv.conf

          require_root() {
            if [ "$(id -u)" -ne 0 ]; then
              echo "Run as root: sudo warp-full $*" >&2
              exit 1
            fi
          }

          make_resolv_conf_editable() {
            chattr -i "$resolv_conf" 2>/dev/null || true

            if [ -L "$resolv_conf" ]; then
              tmp="$(mktemp)"
              cp -L "$resolv_conf" "$tmp"
              rm -f "$resolv_conf"
              install -m 0644 "$tmp" "$resolv_conf"
              rm -f "$tmp"
            else
              touch "$resolv_conf"
              chmod 0644 "$resolv_conf"
            fi
          }

          restore_unbound_dns() {
            chattr -i "$resolv_conf" 2>/dev/null || true
            rm -f "$resolv_conf"
            install -m 0644 /dev/stdin "$resolv_conf" <<'EOF'
          nameserver 127.0.0.1
          options edns0
          EOF
          }

          case "''${1:-}" in
            on)
              require_root "$@"
              systemctl stop protect-resolv-conf.service 2>/dev/null || true
              make_resolv_conf_editable
              warp-cli mode warp
              warp-cli connect
              ;;
            off)
              require_root "$@"
              warp-cli disconnect || true
              restore_unbound_dns
              systemctl restart unbound.service
              systemctl restart protect-resolv-conf.service
              ;;
            status)
              warp-cli status
              ;;
            *)
              echo "Usage: warp-full {on|off|status}" >&2
              exit 2
              ;;
          esac
        '';
      })
    ];
    systemd.packages = [pkgs.cloudflare-warp]; # for warp-cli
    systemd.targets.multi-user.wants = ["warp-svc.service"]; # causes warp-svc to be started automatically
  };
}
