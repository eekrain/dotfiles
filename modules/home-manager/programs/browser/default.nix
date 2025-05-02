{
  inputs,
  config,
  lib,
  pkgs,
  ...
}:
with lib; let
  cfg = config.myHmModules.programs;
  system = "x86_64-linux";
in {
  # home.nix
  imports = [inputs.zen-browser.homeModules.twilight];

  options.myHmModules.programs.browser = mkEnableOption "Enable browser settings";

  config = mkIf cfg.browser {
    home.packages = [
      pkgs.brave
    ];

    programs.zen-browser = {
      enable = true;
      nativeMessagingHosts = [pkgs.firefoxpwa];
      policies = {
        DisableAppUpdate = true;
        DisableTelemetry = true;
        # find more options here: https://mozilla.github.io/policy-templates/
      };
    };
  };
}
