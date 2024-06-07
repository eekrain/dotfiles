{ config, lib, pkgs, ... }:
with lib;
let
  cfg = config.myModules.networking;
in
{

  config = mkIf (cfg.proxyWith == "dae") {
    networking.firewall.enable = lib.mkForce false;
    services.dae.enable = true;
    services.dae.configFile = ./config.dae;
  };
}
