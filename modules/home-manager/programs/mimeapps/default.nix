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
            # Vscode
            (subtypes "text" "code.desktop"
              ["plain" "html"])
            {"application/json" = "code.desktop";}

            # Videos
            {"video/*" = "mpv.desktop";}
            (subtypes "application" "mpv.desktop"
              ["ogg" "x-ogg" "mxf" "sdp" "smil" "x-smil" "streamingmedia" "x-streamingmedia" "vnd.rn-realmedia" "vnd.rn-realmedia-vbr" "x-extension-m4a" "x-extension-mp4" "vnd.ms-asf" "x-matroska" "x-ogm" "x-shorten" "x-mpegurl" "vnd.apple.mpegurl" "x-cue"])
            {"audio/*" = "io.bassi.Amberol.desktop";}

            # Images
            (subtypes "image" "com.interversehq.qView.desktop"
              ["bmp" "x-win-bitmap" "gif" "icns" "x-icon" "jpeg" "jpg" "x-portable-bitmap" "x-portable-graymap" "png" "x-portable-pixmap" "svg+xml" "tiff" "vnd.wap.wbmp" "webp" "x-xbitmap" "x-xpixmap" "apng" "avif" "avif-sequence" "x-sgi-bw" "aces" "x-exr" "vnd.radiance" "heic" "heif" "jxl" "openraster" "vnd.zbrush.pcx" "x-pcx" "x-pic" "vnd.adobe.photoshop" "psd" "x-sun-raster" "x-rgb" "x-sgi-rgba" "sgi" "x-tga" "x-xcf"])
            (subtypes "application" "com.interversehq.qView.desktop"
              ["x-navi-animation" "x-krita" "x-photoshop" "photoshop" "psd"])

            # Zen Browser
            (subtypes "x-scheme-handler" "zen.desktop"
              ["http" "https" "chrome"])
            (subtypes "application" "zen.desktop"
              ["pdf" "rdf+xml" "rss+xml" "xhtml+xml" "xhtml_xml" "xml" "x-xpinstall" "xhtml+xml"])
            {"text/xml" = "zen.desktop";}

            # Archive
            {"inode/directory" = "org.gnome.Nautilus.desktop";}
            (subtypes "application" "org.gnome.Nautilus.desktop"
              ["inode/directory" "x-7z-compressed" "x-7z-compressed-tar" "x-bzip" "x-bzip-compressed-tar" "x-compress" "x-compressed-tar" "x-cpio" "x-gzip" "x-lha" "x-lzip" "x-lzip-compressed-tar" "x-lzma" "x-lzma-compressed-tar" "x-tar" "x-tarz" "x-xar" "x-xz" "x-xz-compressed-tar" "zip" "gzip" "bzip2" "vnd.rar" "zstd" "x-zstd-compressed-tar"])
          ]
        );
    };
  };
}
