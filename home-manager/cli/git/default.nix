{ config, pkgs, lib, ... }:
{
  home.packages = [ pkgs.gitAndTools.gh ];
  programs = {
    git = {
      enable = true;
      extraConfig = ''
        [credential "https://github.com"]
            helper = "${pkgs.gitAndTools.gh} auth git-credential"
      '';

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
