{
  config,
  inputs,
  pkgs,
  lib,
  ...
}:
with lib; let
  cfg = config.myModules.addons;
in {
  options.myModules.addons = {
    enableNixLd = mkEnableOption "Enable nix-ld";
    enableAndroidAdb = mkEnableOption "Enable android adb connection";
    enableDocker = mkEnableOption "Enable default docker settings";
    enableVirtualbox = mkEnableOption "Enable default virtualbox settings";
  };

  config = mkMerge [
    (mkIf cfg.enableNixLd {
      # Nix-ld
      programs.nix-ld.enable = true;
    })
    (mkIf cfg.enableAndroidAdb {
      # For android development
      programs.adb.enable = true;
    })
    (mkIf cfg.enableDocker {
      # My default docker settings
      virtualisation.docker.enable = true;
      users.extraGroups.docker.members = ["eekrain"];
    })
    (mkIf cfg.enableVirtualbox {
      # Virtual box
      virtualisation.virtualbox.host.enable = true;
      virtualisation.virtualbox.host.package = pkgs.pkgs2405.virtualbox;
      users.extraGroups.vboxusers.members = ["eekrain"];
    })
  ];
}
