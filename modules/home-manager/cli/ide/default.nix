{
  lib,
  config,
  pkgs,
  ...
}:
with lib; let
  cfg = config.myHmModules.cli;
in {
  options.myHmModules.cli.ide = mkEnableOption "Enable ide settings";
  config = mkIf cfg.git {
    home.packages = [pkgs.helix];

    # programs.zellij = {
    #   enable = true;
    #   settings = {
    #     theme = "Catppuccin Mocha";
    #     editor = {
    #       line-number = "relative";
    #       lsp.display-messages = true;
    #     };
    #   };
    # };
  };
}
