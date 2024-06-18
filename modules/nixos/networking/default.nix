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
  ];

  options.myModules.networking.enable = mkEnableOption "Enable networking functions";

  config = mkIf cfg.enable {
    # Set your time zone.
    time.timeZone = "Asia/Jakarta";
    services.ntp.enable = true;
    programs.ssh.startAgent = true;

    networking = {
      networkmanager.enable = true;

      extraHosts = ''
        127.0.0.1 mydomain.com
        127.0.0.1 dashboard.mydomain.com
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
