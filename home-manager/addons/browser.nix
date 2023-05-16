{ config, pkgs, ... }:
{
  programs.brave = {
    enable = true;
    extensions = [
      {
        # bitwarden
        id = "nngceckbapebfimnlniiiahkandclblb";
      }
      {
        id = "ahmpjcflkgiildlgicmcieglgoilbfdp";
      }
    ];
  };


  home.packages = with pkgs; [ freedownloadmanager ];
  xdg.desktopEntries = {
    freedownloadmanager = {
      name = "Free Download Manager";
      exec = "env QT_QPA_PLATFORM=xcb freedownloadmanager %U";
      type = "Application";
      terminal = false;
      icon = "${pkgs.freedownloadmanager}/freedownloadmanager/icon.png";
      comment = ''FDM is a powerful modern download accelerator and organizer.'';
      settings = {
        StartupNotify = "true";
        Categories = "Network;FileTransfer;P2P;GTK;";
        Keywords = "download;manager;free;fdm;";
      };
    };
  };
}
