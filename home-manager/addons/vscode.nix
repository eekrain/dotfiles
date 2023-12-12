{ config, pkgs, lib, ... }:
{
  home.packages = [
    (pkgs.vscode.override {
      commandLineArgs = "--enable-features=WaylandWindowDecorations --ozone-platform-hint=auto";
      # isInsiders = true;
    })
  ];
}
