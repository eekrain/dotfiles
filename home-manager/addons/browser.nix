{ config, pkgs, lib, osConfig, ... }:
{
  home.packages = with pkgs; [ firefox-unwrapped aria ];
  programs.brave = {
    enable = true;
    package = (pkgs.brave.override {
      libvaSupport = true;
      vulkanSupport = if osConfig.hardware.nvidia.enable then false else true;
      enableVideoAcceleration = true;
      commandLineArgs = if osConfig.hardware.nvidia.enable then "--ozone-platform=x11" else "";
    });
    extensions = [
      {
        # bitwarden
        id = "nngceckbapebfimnlniiiahkandclblb";
      }
      {
        # Aria2 Explorer Download Manager
        id = "mpkodccbngfoacfalldjimigbofkhgjn";
      }
    ];
  };

  xdg.desktopEntries = lib.mkMerge [
    (lib.mkIf (osConfig.hardware.nvidia.enable) {
      brave-browser = {
        name = "Brave Web Browser";
        genericName = "Web Browser";
        exec = "nvidia-offload ${pkgs.brave}/bin/brave -ozone-platform=x11 %U";
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
            exec = "nvidia-offload ${pkgs.brave}/bin/brave -ozone-platform=x11";
          };
          "new-private-window" = {
            name = "New Incognito Window";
            exec = "nvidia-offload ${pkgs.brave}/bin/brave -ozone-platform=x11 --incognito";
          };
        };
      };
    })
  ];
}
