{ config, pkgs, lib, ... }:
{
  home.packages = [ pkgs.gitAndTools.gh ];
  programs = {
    git = {
      enable = true;
      extraConfig = {
        pull.rebase = false;
        # Follows gitCredentialHelper from home-manager gh module 
        credential."https://github.com" = {
          helper = "${pkgs.gitAndTools.gh}/bin/gh auth git-credential";
        };
      };

      # userName = "Ardian Eka Candra";
      # userEmail = "ardianoption@gmail.com";
    };

    # Disable gh from home manager for the time being
    # gh = {
    #   enable = true;
    #   gitCredentialHelper.enable = lib.mkForce true;
    # };
  };
}
