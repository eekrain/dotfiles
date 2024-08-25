{
  config,
  lib,
  pkgs,
  ...
}:
with lib; let
  cfg = config.myHmModules.programs;
in {
  options.myHmModules.programs.mimeapps = mkEnableOption "Enable mimeapps settings";

  # xdg.mimeApps for configuring default apps to open a file for a spesific format
  config = mkIf cfg.mimeapps {
    xdg.mimeApps = {
      enable = true;
      defaultApplications =
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
            {"text/plain" = "code.desktop";}

            # Media
            {"video/*" = "mpv.desktop";}
            (subtypes "application" "mpv.desktop"
              ["ogg" "x-ogg" "mxf" "sdp" "smil" "x-smil" "streamingmedia" "x-streamingmedia" "vnd.rn-realmedia" "vnd.rn-realmedia-vbr" "x-extension-m4a" "x-extension-mp4" "vnd.ms-asf" "x-matroska" "x-ogm" "x-shorten" "x-mpegurl" "vnd.apple.mpegurl" "x-cue"])
            {"audio/*" = "io.bassi.Amberol.desktop";}
            {"image/*" = "com.github.weclaw1.ImageRoll.desktop";}

            # Zen Browser
            {"text/html" = "zen.desktop";}
            (subtypes "x-scheme-handler" "zen.desktop"
              ["http" "https" "ftp" "chrome" "about" "tg" "whatsapp"])
            (subtypes "application" "zen.desktop"
              ["x-extension-htm" "x-extension-html" "x-extension-shtml" "xhtml+xml" "x-extension-xhtml" "x-extension-xht" "pdf"])

            # Archive
            {"inode/directory" = "org.gnome.Nautilus.desktop";}
            (subtypes "application" "org.gnome.Nautilus.desktop"
              ["inode/directory" "x-7z-compressed" "x-7z-compressed-tar" "x-bzip" "x-bzip-compressed-tar" "x-compress" "x-compressed-tar" "x-cpio" "x-gzip" "x-lha" "x-lzip" "x-lzip-compressed-tar" "x-lzma" "x-lzma-compressed-tar" "x-tar" "x-tarz" "x-xar" "x-xz" "x-xz-compressed-tar" "zip" "gzip" "bzip2" "vnd.rar" "zstd" "x-zstd-compressed-tar"])
          ]
        );
    };
  };
}
