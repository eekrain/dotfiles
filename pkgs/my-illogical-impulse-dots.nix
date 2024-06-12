{ lib, stdenv }:
stdenv.mkDerivation rec {
  pname = "my-illogical-impulse-dots";
  version = "0.1";
  src = lib.cleanSource ../.;

  installPhase = ''
    mkdir -p $out/.config
    cp -vr ./modules/home-manager/desktop/hyprland-rice-illogical-impulse/config/* $out/.config
    rm $out/.config/default.nix
  '';

  meta = with lib; {
    description = "My Hyprland Setup with NixOS Flakes";
    homepage = "https://github.com/eekrain/dotfiles";
    license = licenses.mit;
    platforms = platforms.linux;
  };
}
