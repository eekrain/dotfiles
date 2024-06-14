{
  lib,
  stdenv,
  fetchurl,
  ...
}:
stdenv.mkDerivation
{
  pname = "my-icons";
  version = "0.1";
  src = lib.cleanSource ./icons;

  installPhase = ''
    runHook preInstall
    mkdir -p $out/share/icons
    cp -rf ./* $out/share/icons
    runHook postInstall
  '';

  meta = with lib; {
    description = "My icons";
    homepage = "https://github.com/eekrain/dotfiles";
    license = licenses.mit;
    platforms = platforms.all;
    maintainers = with maintainers; [eekrain];
  };
}
