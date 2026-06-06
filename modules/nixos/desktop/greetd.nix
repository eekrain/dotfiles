{
  config,
  lib,
  pkgs,
  ...
}:
with lib; let
  cfg = config.myModules.desktop;
in {
  options.myModules.desktop = {
    greetd = {
      enable = mkEnableOption "Enable greetd display manager";
    };
  };

  config = mkIf cfg.greetd.enable {
    services.greetd = {
      enable = true;
      settings = {
        default_session = {
          command = lib.escapeShellArgs [
            "${pkgs.tuigreet}/bin/tuigreet"
            "--time"
            "--time-format"
            "%I:%M %p | %a • %h | %F"
            "--cmd"
            "start-hyprland"
          ];
          user = "greeter";
        };
      };
    };

    users.users.greeter = {
      isNormalUser = false;
      description = "greetd greeter user";
      extraGroups = ["video" "audio"];
      linger = true;
    };

    environment.systemPackages = with pkgs; [
      tuigreet
    ];

    security.pam.services.greetd.enableGnomeKeyring = true;
  };
}
