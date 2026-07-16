{
  lib,
  rustPlatform,
  pkg-config,
  makeWrapper,
  dbus,
  openssl,
  lxc,
  e2fsprogs,
  util-linux,
  _sources,
}:
let
  inherit (_sources.waydroidsu) src;
in
rustPlatform.buildRustPackage rec {
  pname = "wsu";
  version = _sources.waydroidsu.version;

  inherit src;

  # Cargo.lock ships with the source; avoids hardcoding a cargo hash.
  cargoLock.lockFile = src + "/Cargo.lock";

  nativeBuildInputs = [
    pkg-config
    makeWrapper
  ];

  buildInputs = [
    dbus
    openssl
  ];

  # wsu shells out to host tools at runtime (run as root via sudo).
  # Inject them into PATH so the binary works regardless of the caller's PATH.
  postInstall = ''
    wrapProgram $out/bin/${pname} \
      --prefix PATH : ${
        lib.makeBinPath [
          lxc
          e2fsprogs
          util-linux
        ]
      }
  '';

  meta = {
    description = "CLI Magisk manager and installer for Waydroid";
    homepage = "https://github.com/mistrmochov/WaydroidSU";
    license = lib.licenses.gpl3Plus;
    platforms = [
      "x86_64-linux"
      "aarch64-linux"
    ];
    mainProgram = "wsu";
  };
}
