{ config, lib, pkgs, ... }:
with lib;
let
  cfg = config.myHmModules.programs;
in
{
  config = mkIf cfg.vscode {
    programs.vscode = {
      enable = true;
      package = pkgs.vscode;
    };
  };
}
