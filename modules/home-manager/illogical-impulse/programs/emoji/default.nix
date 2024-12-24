{
  lib,
  config,
  pkgs,
  ...
}:
with lib; let
  fuzzel-emoji = lib.fileContents ./fuzzel-emoji.sh;
in {
  home.file.".local/bin/fuzzel-emoji".text = ''
    #!${pkgs.bash}/bin/bash
    ${fuzzel-emoji}
  '';
  home.file.".local/bin/fuzzel-emoji".executable = true;
}
