{
  config,
  lib,
  pkgs,
  ...
}:
with lib; let
  cfg = config.myModules.networking;
in {
  imports = [
    ./redsocks.nix
    ./clash.nix
    ./cloudflare-warp
  ];

  options.myModules.networking.enable = mkEnableOption "Enable networking functions";
  options.myModules.networking.cloudflared = mkEnableOption "Install cloudflared";

  config = mkIf cfg.enable {
    # Set your time zone.
    time.timeZone = "Asia/Jakarta";
    services.ntp.enable = true;

    environment.systemPackages = with pkgs;
      []
      ++ lib.optionals (cfg.cloudflared) [
        pkgs2411.cloudflared
      ];

    networking = {
      networkmanager.enable = true;

      extraHosts = ''
        127.0.0.1 mydomain.com
        127.0.0.1 dashboard.mydomain.com
        127.0.0.1 seller-mpp.localhost
        127.0.0.1 buyer-mpp.localhost
      '';

      firewall = {
        enable = lib.mkDefault true;
        allowedTCPPortRanges = [
          {
            from = 0;
            to = 65535;
          }
        ];
        allowedUDPPortRanges = [
          {
            from = 0;
            to = 65535;
          }
        ];
      };
    };
  };
}
