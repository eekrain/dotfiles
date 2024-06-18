{
  config,
  lib,
  pkgs,
  ...
}:
with lib; let
  cfg = config.myModules.networking;
in {
  options.myModules.networking.clash = mkEnableOption "Enable clash-verge settings";

  config = mkIf cfg.clash {
    networking.firewall.enable = lib.mkForce false;
    programs.clash-verge.enable = true;
  };
}
