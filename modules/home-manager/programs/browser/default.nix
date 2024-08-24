{
  config,
  lib,
  pkgs,
  ...
}:
with lib; let
  cfg = config.myHmModules.programs;
in {
  options.myHmModules.programs.browser = mkEnableOption "Enable browser settings";

  config = mkIf cfg.browser {
    # home.packages = [
    #   inputs.zen-browser.packages."x86_64-linux".specific
    # ];
  };
}
