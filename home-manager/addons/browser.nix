{ config, pkgs, ... }:
{
  home.packages = [ pkgs.firefox-unwrapped ];
  programs.brave = {
    enable = true;
    package = (pkgs.brave.override { vulkanSupport = true; enableVideoAcceleration = true; });
    extensions = [
      {
        # bitwarden
        id = "nngceckbapebfimnlniiiahkandclblb";
      }
      {
        # freedownloadmanager
        id = "ahmpjcflkgiildlgicmcieglgoilbfdp";
      }
    ];
  };
}
