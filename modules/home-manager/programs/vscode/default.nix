{ config, lib, pkgs, ... }:
with lib;
let
  cfg = config.myHmModules.programs;
in
{
  config = mkIf cfg.vscode {
    home.packages = [
      (pkgs.vscode.override {
        # gnome-libsecret to detect the correct keyring to use on my system
        commandLineArgs = ''--password-store=gnome --enable-features=UseOzonePlatform --ozone-platform=wayland'';
      })
    ];
  };
}
