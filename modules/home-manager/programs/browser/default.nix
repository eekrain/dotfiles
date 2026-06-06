{
  inputs,
  config,
  lib,
  ...
}:
with lib; let
  cfg = config.myHmModules.programs;
in {
  options.myHmModules.programs.browser = mkEnableOption "Enable browser settings";

  imports = [inputs.zen-browser.homeModules.twilight];

  config = mkIf cfg.browser {
    programs.zen-browser = {
      enable = true;
      setAsDefaultBrowser = true;
    };
  };
}
