{ config, pkgs, lib, ... }:
{
  home.packages = [
    (pkgs.vscode.override {
      commandLineArgs = "--ozone-platform=x11";
      # isInsiders = true;
    })
  ];
}
