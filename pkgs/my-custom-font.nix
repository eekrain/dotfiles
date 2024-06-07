{ lib, stdenv, fetchurl, ... }:

stdenv.mkDerivation
{
  # version will resolve to the latest available on gitub
  pname = "my-custom-fonts";
  version = "1.0";
  src = fetchurl {
    url = "https://github.com/eekrain/dotfiles/releases/download/1.0/my_custom_fonts.tar.xz";
    sha256 = "sha256-J2xoO1hAnKkbRAMUKKuDJ85DBGRCHSIeDIiDD1+PSS8=";
  };

  unpackPhase = ''
    runHook preUnpack
    mkdir my-custom-fonts
    tar -C my-custom-fonts -xf $src
    runHook postUnpack
  '';

  installPhase = ''
    runHook preInstall
    mkdir -p $out/share/fonts/{truetype,opentype}
    find ./my-custom-fonts -name '*.otf' -exec install -Dt $out/share/fonts/opentype {} \;
    find ./my-custom-fonts -name '*.ttf' -exec install -Dt $out/share/fonts/truetype {} \;
    runHook postInstall
  '';

  meta = with lib; {
    description = "My bspwm custom fonts for github:eekrain/dotfiles";
    homepage = "https://github.com/eekrain/dotfiles";
    license = licenses.mit;
    platforms = platforms.all;
    maintainers = with maintainers; [ eekrain ];
  };
}
