{ config, lib, pkgs, ... }:
with lib;
{
  imports = [
    ./virtualization.nix
  ];

  options.myModules.addons = {
    enableAndroidAdb = mkEnableOption "Enable android adb connection";
    enableDocker = mkEnableOption "Enable default docker settings";
    enableVirtualbox = mkEnableOption "Enable default virtualbox settings";
  };
}
