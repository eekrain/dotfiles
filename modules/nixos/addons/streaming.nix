{
  config,
  inputs,
  pkgs,
  lib,
  ...
}:
with lib;
let
  cfg = config.myModules.addons;
in
{
  options.myModules.addons = {
    streaming = mkEnableOption "Enable streaming services (localsend, avahi for casting)";
  };

  config = mkIf cfg.streaming {
    programs.localsend = {
      enable = true;
      openFirewall = true;
    };

    services.avahi = {
      enable = true;
      nssmdns4 = true;
      publish = {
        enable = true;
        userServices = true;
      };
    };

    networking.firewall.allowedTCPPorts = [ 8010 ];
  };
}
