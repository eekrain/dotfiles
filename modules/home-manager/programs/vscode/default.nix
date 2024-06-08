{ config, pkgs, lib, ... }:
{
  home.packages = [
    (pkgs.vscode.override {
      # gnome-libsecret to detect the correct keyring to use on my system
      commandLineArgs = ''--password-store="gnome-libsecret"'';
    })
  ];
}
