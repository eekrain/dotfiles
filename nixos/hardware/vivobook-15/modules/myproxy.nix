{ lib, pkgs, config, inputs, ... }:
with lib;
let
  cfg = config.services.myproxy;
in
{
  options.services.myproxy = {
    enable = mkEnableOption "Enable custom proxy";
  };

  config = mkIf cfg.enable {
    services.redsocks = {
      enable = true;
      log_debug = true;
      log_info = true;
      redsocks = [
        {
          port = 55555;
          proxy = "172.19.0.1:2080";
          type = "socks5";
          redirectCondition = true;
          redirectInternetOnly = true;
        }
      ];
    };
  };
}
