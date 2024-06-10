{ stdenv
, lib
, buildPythonPackage
, fetchurl
, pythonRelaxDepsHook
, pillow
, glib
,
}:

buildPythonPackage rec {
  pname = "python-materialyoucolor";
  version = "2.0.9";
  src = fetchurl {
    url = "https://pypi.org/packages/source/m/materialyoucolor/materialyoucolor-2.0.9.tar.gz";
    sha256 = "sha256-J35//h3tWn20f5ej6OXaw4NKnxung9q7m0E4Zf9PUw4=";
  };

  nativeBuildInputs = [ pythonRelaxDepsHook ];
  pythonRelaxDeps = [ "Pillow" ];

  buildInputs = [
    glib
  ];

  propagatedBuildInputs = [
    pillow
  ];

  # No tests implemented.
  doCheck = false;

  pythonImportsCheck = [ "materialyoucolor" ];

  meta = with lib; {
    homepage = "https://pypi.org/project/materialyoucolor/";
    description = "Material You color generation algorithms in pure python!";
    license = licenses.mit;
    maintainers = with maintainers; [ eekrain ];
  };
}
