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
      vscode
      windsurf
      code-cursor
    ];
  };
}
