{
  config,
  lib,
  pkgs,
  ...
}:
with lib; let
  cfg = config.myHmModules.programs;
in {
  options.myHmModules.programs.vscode = mkEnableOption "Enable vscode settings";

  config = mkIf cfg.vscode {
    home.packages = with pkgs; [
      # nix formatter
      alejandra
      (vscode.override {
        # gnome-libsecret to detect the correct keyring to use on my system
        commandLineArgs = ''--password-store="gnome-libsecret" --enable-features=UseOzonePlatform --ozone-platform=wayland'';
      })
    ];
  };
}
