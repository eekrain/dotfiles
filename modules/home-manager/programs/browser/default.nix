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
        AutofillAddressEnabled = true;
        AutofillCreditCardEnabled = false;
        DisableAppUpdate = true;
        DisableFeedbackCommands = true;
        DisableFirefoxStudies = true;
        DisablePocket = true;
        DisableTelemetry = true;
        DontCheckDefaultBrowser = true;
        NoDefaultBookmarks = true;
        OfferToSaveLogins = false;
        EnableTrackingProtection = {
          Value = true;
          Locked = true;
          Cryptomining = true;
          Fingerprinting = true;
        };
      };

      profiles."default" = {
        containersForce = true;
        containers = {
          Personal = {
            color = "purple";
            icon = "vacation";
            id = 1;
          };
          Work = {
            color = "blue";
            icon = "briefcase";
            id = 2;
          };
          Shopping = {
            color = "yellow";
            icon = "dollar";
            id = 3;
          };
        };
        spacesForce = true;
        spaces = let
          containers = config.programs.zen-browser.profiles."default".containers;
        in {
          "Space" = {
            id = "c6de089c-410d-4206-961d-ab11f988d40a";
            position = 1000;
          };
          "Work" = {
            id = "cdd10fab-4fc5-494b-9041-325e5759195b";
            icon = "chrome://browser/skin/zen-icons/selectable/star-2.svg";
            container = containers."Work".id;
            position = 2000;
          };
          "Shopping" = {
            id = "78aabdad-8aae-4fe0-8ff0-2a0c6c4ccc24";
            icon = "💸";
            container = containers."Shopping".id;
            position = 3000;
          };
        };
      };
    };
  };
}
