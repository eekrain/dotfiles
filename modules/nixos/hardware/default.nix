{
  config,
  lib,
  pkgs,
  ...
}:
with lib; let
  cfg = config.myModules.hardware;
in {
  imports = [
    ./audio.nix
    ./bluetooth.nix
    ./gpu
    ./power-management.nix
    ./suspend-then-hybernate.nix
  ];
  options.myModules.hardware = {
    audio = mkEnableOption "Enable custom audio settings";
    bluetooth = mkEnableOption "Enable custom bluetooth settings";
    suspendThenHybernate = mkEnableOption "Enable suspend-then-hybernate configuration";
  };
}
