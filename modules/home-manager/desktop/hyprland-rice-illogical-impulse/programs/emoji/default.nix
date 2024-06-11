{ lib, config, pkgs, ... }:
with lib;
let
  cfg = config.myHmModules.desktop.hyprland;
  fuzzel-emoji = lib.fileContents ./fuzzel-emoji.sh;
in
{
  config = mkIf (cfg.riceSetup == "hyprland-rice-illogical-impulse") {
    home.file.".local/bin/fuzzel-emoji".text = ''
      #!${pkgs.bash}/bin/bash
      ${fuzzel-emoji}
    '';
    home.file.".local/bin/fuzzel-emoji".executable = true;
  };
}

