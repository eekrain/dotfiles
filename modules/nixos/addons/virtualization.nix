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
    android = mkEnableOption "Enable android adb connection";
    docker = mkEnableOption "Enable default docker settings";
    virtualbox = mkEnableOption "Enable default virtualbox settings";
    waydroid = mkEnableOption "Enable default virtualbox settings";
  };

  config = mkMerge [
    (mkIf cfg.android {
      # Install Distrobox and keep Android tools for ADB hardware detection
      # NEEDS DOCKER INSTALLED, ENABLE THE DOCKER OPTION BELOW
      environment.systemPackages = with pkgs; [
        distrobox
        android-tools # Keep this so your host can still talk to physical phones!
      ];

      virtualisation.libvirtd.enable = true; # Optional, but recommended for KVM management
    })

    (mkIf cfg.docker {
      # My default docker settings
      virtualisation.docker.enable = true;
      users.extraGroups.docker.members = [ "eekrain" ];
    })

    (mkIf cfg.virtualbox {
      # Virtual box
      virtualisation.virtualbox.host.enable = true;
      virtualisation.virtualbox.host.package = pkgs.pkgs2411.virtualbox;
      users.extraGroups.vboxusers.members = [ "eekrain" ];
    })

    (mkIf cfg.waydroid {
      virtualisation.waydroid.enable = true;
    })
  ];
}
