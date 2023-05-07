{ lib, stdenv, fetchFromGitHub }:

stdenv.mkDerivation rec {
  pname = "sddm-sugar-candy";
  version = "a1fae5159c8f7e44f0d8de124b14bae583edb5b8";

  src = fetchFromGitHub ({
    owner = "eekrain";
    repo = "sddm-sugar-candy";
    rev = "a1fae5159c8f7e44f0d8de124b14bae583edb5b8";
    fetchSubmodules = false;
    sha256 = "sha256-p2d7I0UBP63baW/q9MexYJQcqSmZ0L5rkwK3n66gmqM=";
  });
  date = "2020-02-01";

  installPhase = ''
    mkdir -p $out/share/sddm/themes/sugar-candy
    cp -vr * $out/share/sddm/themes/sugar-candy
  '';

  meta = with lib; {
    description = "The sweetest login theme avaliable for SDDM";
    homepage = "https://framagit.org/MarianArlt/sddm-sugar-candy";
    license = licenses.gpl3Only;
    platforms = platforms.linux;
  };
}
