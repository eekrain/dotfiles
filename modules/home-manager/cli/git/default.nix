{ lib, config, pkgs, ... }:
with lib;
let
  cfg = config.myHmModules.cli;
in
{
  options.myHmModules.cli.git = mkEnableOption "Enable git settings";
  config = mkIf cfg.git {
    home.packages = [ pkgs.gh ];
    programs = {
      git = {
        enable = true;
        extraConfig = {
          pull.rebase = false;
          # Follows gitCredentialHelper from home-manager gh module 
          credential."https://github.com" = {
            helper = "${pkgs.gh}/bin/gh auth git-credential";
          };
        };

        userName = "Ardian Eka Candra";
        userEmail = "ardianoption@gmail.com";
      };

      # Disable gh from home manager for the time being
      gh = {
        enable = true;
        gitCredentialHelper.enable = lib.mkForce true;
      };
    };
  };
}
