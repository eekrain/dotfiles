{
  config,
  lib,
  pkgs,
  ...
}:
with lib; let
  cfg = config.myHmModules.programs;
in {
  options.myHmModules.programs.browser = mkEnableOption "Enable browser settings";

  config = mkIf cfg.browser {
    home.packages = [
      (pkgs.google-chrome.override {
        libvaSupport = true;
        commandLineArgs = ''--ozone-platform-hint=wayland --gtk-version=4 --ignore-gpu-blocklist --enable-features=TouchpadOverscrollHistoryNavigation'';
      })
    ];
    programs.brave = {
      enable = true;
      package = pkgs.brave.override {
        libvaSupport = true;
        vulkanSupport = true;
        enableVideoAcceleration = true;
        commandLineArgs = ''--ozone-platform-hint=wayland --gtk-version=4 --ignore-gpu-blocklist --enable-features=TouchpadOverscrollHistoryNavigation'';
      };
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

    # xdg.desktopEntries = lib.mkMerge [
    #   (lib.mkIf (osConfig.myModules.hardware.gpu == "nvidia") {
    #     brave-browser = {
    #       name = "Brave Web Browser";
    #       genericName = "Web Browser";
    #       exec = "nvidia-offload ${pkgs.brave}/bin/brave %U";
    #       type = "Application";
    #       terminal = false;
    #       icon = "brave-browser";
    #       comment = ''Access the Internet.'';
    #       settings = {
    #         StartupNotify = "true";
    #         Categories = "Network;WebBrowser;";
    #         MimeType = "application/pdf;application/rdf+xml;application/rss+xml;application/xhtml+xml;application/xhtml_xml;application/xml;image/gif;image/jpeg;image/png;image/webp;text/html;text/xml;x-scheme-handler/http;x-scheme-handler/https;x-scheme-handler/ipfs;x-scheme-handler/ipns;";
    #       };
    #       actions = {
    #         "new-window" = {
    #           name = "New Window";
    #           exec = "nvidia-offload ${pkgs.brave}/bin/brave";
    #         };
    #         "new-private-window" = {
    #           name = "New Incognito Window";
    #           exec = "nvidia-offload ${pkgs.brave}/bin/brave --incognito";
    #         };
    #       };
    #     };
    #   })
    # ];
  };
}
