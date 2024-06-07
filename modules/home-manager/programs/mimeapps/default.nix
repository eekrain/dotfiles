{ config, lib, pkgs, ... }:
with lib;
let
  cfg = config.myHmModules.programs;
in
{
  config = mkIf cfg.mimeapps {
    xdg.mimeApps = {
      enable = true;
      defaultApplications = lib.zipAttrsWith
        (_: values: values)
        (
          let
            subtypes = type: program: subt:
              builtins.listToAttrs (builtins.map
                (x: { name = type + "/" + x; value = program; })
                subt);
          in
          [
            { "text/plain" = "code.desktop"; }
            { "video/*" = "mpv.desktop"; }
            { "audio/*" = "org.gnome.Lollypop.desktop"; }
            # Brave Browser
            { "text/html" = "brave.desktop"; }
            (subtypes "x-scheme-handler" "brave.desktop"
              [ "http" "https" "ftp" "chrome" "about" ])
            (subtypes "application" "brave.desktop"
              [ "x-extension-htm" "x-extension-html" "x-extension-shtml" "xhtml+xml" "x-extension-xhtml" "x-extension-xht" "pdf" ])
            # # Wavebox
            # (subtypes "x-scheme-handler" "Wavebox.desktop"
            #   [ "tg" "whatsapp" ])
            # Image
            (subtypes "image" "imv-dir.desktop"
              [ "png" "jpeg" "gif" "svg" "svg+xml" "tiff" "x-tiff" "x-dcraw" ])
            # Archive
            (subtypes "application" "peazip.desktop"
              [ "bzip2" "gzip" "vnd.android.package-archive" "vnd.ms-cab-compressed" "vnd.debian.binary-package" "x-7z-compressed" "x-7z-compressed-tar" "x-ace" "x-alz" "x-ar" "x-archive" "x-arj" "x-brotli" "x-bzip-brotli-tar" "x-bzip" "x-bzip-compressed-tar" "x-bzip1" "x-bzip1-compressed-tar" "x-cabinet" "x-cd-image" "x-compress" "x-compressed-tar" "x-cpio" "x-chrome-extension" "x-deb" "x-ear" "x-ms-dos-executable" "x-gtar" "x-gzip" "x-gzpostscript" "x-java-archive" "x-lha" "x-lhz" "x-lrzip" "x-lrzip-compressed-tar" "x-lz4" "x-lzip" "x-lzip-compressed-tar" "x-lzma" "x-lzma-compressed-tar" "x-lzop" "x-lz4-compressed-tar" "x-ms-wim" "x-rar" "x-rar-compressed" "x-rpm" "x-source-rpm" "x-rzip" "x-rzip-compressed-tar" "x-tar" "x-tarz" "x-tzo" "x-stuffit" "x-war" "x-xar" "x-xz" "x-xz-compressed-tar" "x-zip" "x-zip-compressed" "x-zstd-compressed-tar" "x-zoo" "zip" "zstd" ])
          ]
        );
    };
  };
}
