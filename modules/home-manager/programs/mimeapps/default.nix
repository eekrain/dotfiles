{
  config,
  lib,
  pkgs,
  ...
}:
with lib; let
  cfg = config.myHmModules.programs;
  myAssociation =
    lib.zipAttrsWith
    (_: values: values)
    (
      let
        subtypes = type: program: subt:
          builtins.listToAttrs (builtins.map
            (x: {
              name = type + "/" + x;
              value = program;
            })
            subt);
      in [
        # Zen Browser
        {"text/xml" = "zen.desktop";}
        {"text/html" = "zen.desktop";}
        (subtypes "x-scheme-handler" "zen.desktop"
          ["http" "https" "chrome"])
        (
          subtypes "application" "zen.desktop"
          ["pdf" "rdf+xml" "rss+xml" "xhtml+xml" "xhtml_xml" "xml" "x-xpinstall" "xhtml+xml" "x-extension-xhtml" "x-extension-xht" "x-extension-htm" "x-extension-html" "x-extension-shtml"]
        )

        # Vscode
        (subtypes "text" "code.desktop"
          ["plain"])
        {"application/json" = "code.desktop";}

        # Videos
        {"video/*" = "mpv.desktop";}
        (subtypes "application" "mpv.desktop"
          ["ogg" "x-ogg" "mxf" "sdp" "smil" "x-smil" "streamingmedia" "x-streamingmedia" "vnd.rn-realmedia" "vnd.rn-realmedia-vbr" "x-extension-m4a" "x-extension-mp4" "vnd.ms-asf" "x-matroska" "x-ogm" "x-shorten" "x-mpegurl" "vnd.apple.mpegurl" "x-cue"])
        {"audio/*" = "io.bassi.Amberol.desktop";}

        # Images
        {"image/*" = "com.interversehq.qView.desktop";}
        (subtypes "application" "com.interversehq.qView.desktop"
          ["x-navi-animation" "x-krita" "x-photoshop" "photoshop" "psd"])

        # Archive
        {"inode/directory" = "org.gnome.Nautilus.desktop";}
        (subtypes "application" "org.gnome.Nautilus.desktop"
          ["inode/directory" "x-7z-compressed" "x-7z-compressed-tar" "x-bzip" "x-bzip-compressed-tar" "x-compress" "x-compressed-tar" "x-cpio" "x-gzip" "x-lha" "x-lzip" "x-lzip-compressed-tar" "x-lzma" "x-lzma-compressed-tar" "x-tar" "x-tarz" "x-xar" "x-xz" "x-xz-compressed-tar" "zip" "gzip" "bzip2" "vnd.rar" "zstd" "x-zstd-compressed-tar"])

        # Chat app
        {"x-scheme-handler/discord" = "vesktop.desktop";}
        {"x-scheme-handler/msteams" = "teams-for-linux.desktop";}
        {"x-scheme-handler/whatsapp" = "com.github.xeco23.WasIstLos.desktop";}

        #Motrix download manager
        {"application/x-bittorrent" = "motrix.desktop";}
        (subtypes "x-scheme-handler" "motrix.desktop"
          ["magnet" "mo" "motrix" "magnet" "thunder"])
      ]
    );
in {
  options.myHmModules.programs.mimeapps = mkEnableOption "Enable mimeapps settings";

  # xdg.mimeApps for configuring default apps to open a file for a spesific format
  config = mkIf cfg.mimeapps {
    xdg.mimeApps = {
      enable = true;
      defaultApplications = myAssociation;
      associations.added = myAssociation;
    };
  };
}
