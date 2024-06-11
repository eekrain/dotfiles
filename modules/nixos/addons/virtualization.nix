{ config, inputs, pkgs, lib, ... }:
with lib;
let
  cfg = config.myModules.addons;
in
{
  config = mkMerge [
    (mkIf cfg.enableAndroidAdb {
      # For android development
      programs.adb.enable = true;
    })
    (mkIf cfg.enableDocker {
      # My default docker settings
      virtualisation.docker.enable = true;
      users.extraGroups.docker.members = [ "eekrain" ];
    })
    (mkIf cfg.enableVirtualbox {
      # Virtual box
      virtualisation.virtualbox.host.enable = true;
      virtualisation.virtualbox.host.package = pkgs.pkgs2405.virtualbox;
      virtualisation.virtualbox.host.enableExtensionPack = true;
      users.extraGroups.vboxusers.members = [ "eekrain" ];
    })
  ];

}
