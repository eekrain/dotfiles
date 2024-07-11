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
    environment.systemPackages = [pkgs.cloudflare-warp]; # for warp-svc
    systemd.packages = [pkgs.cloudflare-warp]; # for warp-cli
    systemd.targets.multi-user.wants = ["warp-svc.service"]; # causes warp-svc to be started automatically
  };
}
