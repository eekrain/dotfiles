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
        # freedownloadmanager
        id = "ahmpjcflkgiildlgicmcieglgoilbfdp";
      }
    ];
  };

  home.packages = with pkgs; [ freedownloadmanager ];
  xdg.desktopEntries = {
    brave-browser = {
      name = "Brave Web Browser";
      genericName = "Web Browser";
      exec = "env WLR_DRM_DEVICES=/dev/dri/renderD128 nvidia-offload ${pkgs.brave}/bin/brave %U";
      type = "Application";
      terminal = false;
      icon = "brave-browser";
      comment = ''Access the Internet.'';
      settings = {
        StartupNotify = "true";
        Categories = "Network;WebBrowser;";
        MimeType = "application/pdf;application/rdf+xml;application/rss+xml;application/xhtml+xml;application/xhtml_xml;application/xml;image/gif;image/jpeg;image/png;image/webp;text/html;text/xml;x-scheme-handler/http;x-scheme-handler/https;x-scheme-handler/ipfs;x-scheme-handler/ipns;";
      };
      actions = {
        "new-window" = {
          name = "New Window";
          exec = "env WLR_DRM_DEVICES=/dev/dri/renderD128 nvidia-offload ${pkgs.brave}/bin/brave";
        };
        "new-private-window" = {
          name = "New Incognito Window";
          exec = "env WLR_DRM_DEVICES=/dev/dri/renderD128 nvidia-offload ${pkgs.brave}/bin/brave --incognito";
        };
      };
    };

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
