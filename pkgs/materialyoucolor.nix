{ lib
, buildPythonPackage
, fetchFromGitHub
, fetchurl
, setuptools
, pybind11
, stb
, requests
, rich
, pillow
,
}:
let
  mcu-src = fetchFromGitHub {
    owner = "material-foundation";
    repo = "material-color-utilities";
    rev = "1217346b9416e6e55c83c6e9295f6aed001e852e";
    hash = "sha256-entAI2kFIoPzAxnmE5tmLrTwejOwm1yhqvn+mbnT8HU=";
  };

  test-image = fetchurl {
    name = "test-image.jpg";
    url = "https://unsplash.com/photos/u9tAl8WR3DI/download";
    hash = "sha256-shGNdgOOydgGBtl/JCbTJ0AYgl+2xWvCgHBL+bEoTaE=";
  };
in
buildPythonPackage rec {
  pname = "materialyoucolor";
  version = "2.0.9";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "T-Dynamos";
    repo = "materialyoucolor-python";
    rev = "refs/tags/v${version}";
    hash = "sha256-B+2tUQk2zNVNrR3tPVc16ay+P/M1A3ZRMqxtbSMfyBE=";
  };

  preConfigure = ''
    # Fail if we're using an outdated mcu rev
    grep ${mcu-src.rev} setup.py || (echo "mcu-src.rev doesn't match rev inside setup.py" && false)

    # Circumvent download logic inside of setup.py
    install -Dm644 ${mcu-src}/cpp/{utils/utils,quantize/{wu,wsmeans,lab,celebi}}.* -t materialyoucolor/quantize

    ln -s ${lib.getDev pybind11}/include/pybind11 materialyoucolor/quantize/pybind11
    ln -s ${lib.getDev stb}/include/stb/stb_image.h materialyoucolor/quantize/stb_image.h

    patch --directory=materialyoucolor/quantize --strip=1 -N < quantizer_cpp.patch
  '';

  build-system = [
    setuptools
    pybind11
  ];

  nativeCheckInputs = [
    requests
    rich
    pillow
  ];

  pythonImportsCheck = [
    "materialyoucolor"
    "materialyoucolor.quantize" # ext
  ];

  postInstallCheck = ''
    python tests/test_all.py ${test-image} 1
  '';

  meta = {
    description = "Material You color generation algorithms in python";
    homepage = "https://github.com/T-Dynamos/materialyoucolor-python";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ tomasajt ];
  };
}
