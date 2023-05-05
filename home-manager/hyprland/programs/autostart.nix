{ config, lib, pkgs, ... }:

let
  hypr_autostart = pkgs.writeShellScriptBin "hypr_autostart" ''
    waybar&
  '';
in
{
  home.packages = with pkgs; [
    hypr_autostart
  ];
}
