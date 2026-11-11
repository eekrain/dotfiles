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
      # Publishing enabled + user services + addresses (replaces the
      # removed services.avahi.publish.* options)
      settings.publish = {
        "disable-publishing" = false;
        "disable-user-service-publishing" = false;
        "publish-addresses" = true;
      };
    };

    networking.firewall.allowedTCPPorts = [ 8010 ];
  };
}
