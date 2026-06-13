{
  config,
  pkgs,
  lib,
  ...
}:
with lib;
let
  cfg = config.myHmModules.addons.ruby;
  buildDeps = with pkgs; [
    libyaml
    zlib
    openssl
    pkg-config
    gcc
    gnumake
  ];
in
{
  options.myHmModules.addons.ruby = mkEnableOption "Enable Ruby with writable gem support";

  config = mkIf cfg {
    home.packages =
      with pkgs;
      [
        ruby
        nodejs
        yarn
      ]
      ++ buildDeps;

    home.sessionVariables = {
      GEM_HOME = "$HOME/.gem";
      GEM_PATH = "$HOME/.gem";
    }
    // lib.optionalAttrs (pkgs.stdenv.isLinux) {
      NIX_CC = "${pkgs.stdenv.cc}";
      NIX_CFLAGS_COMPILE = builtins.concatStringsSep " " (
        map (dep: "-I${lib.getDev dep}/include") buildDeps
      );
      NIX_LDFLAGS = builtins.concatStringsSep " " (map (dep: "-L${lib.getLib dep}/lib") buildDeps);
      PKG_CONFIG_PATH = builtins.concatStringsSep ":" (
        map (dep: "${lib.getDev dep}/lib/pkgconfig") buildDeps
      );
    };

    home.sessionPath = [ "$HOME/.gem/bin" ];
  };
}
