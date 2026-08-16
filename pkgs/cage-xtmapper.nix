{
  stdenv,
  autoPatchelfHook,
  fetchurl,
  lib,
  libdrm,
  mesa,
  libglvnd,
  pixman,
  seatd,
  systemd,
  vulkan-loader,
  wayland,
  libxcb,
  xcbutilrenderutil,
  libxkbcommon,
}:
let
  pname = "cage-xtmapper";
  version = "0.2.0";
  src = fetchurl {
    # Prebuilt patched cage (cage_xtmapper) + the orchestrator script, from the
    # v20260208 release. The binary statically links wlroots 0.18.3 (built via
    # meson subproject), so only the common graphics/input stack is dynamic.
    url = "https://github.com/Xtr126/cage-xtmapper/releases/download/v20260208/cage-xtmapper-v${version}.tar";
    sha256 = "1750b72a74f34ced6f128ba2c6a3b5c67b069ae7d1c8093e062465ca936ae244";
  };
in
stdenv.mkDerivation {
  inherit pname version src;

  nativeBuildInputs = [ autoPatchelfHook ];

  buildInputs = [
    libdrm
    mesa # libgbm
    libglvnd # libEGL.so.1 + libGLESv2.so.2 (real drivers from system at runtime)
    pixman
    seatd # libseat.so.1
    systemd # libudev.so.1
    vulkan-loader
    wayland # libwayland-client/server
    libxcb # libxcb.so.1 + the render/present/dri3/xfixes/xinput/shm extensions
    xcbutilrenderutil # libxcb-render-util.so.0
    libxkbcommon
  ];

  sourceRoot = ".";
  dontConfigure = true;
  dontBuild = true;

  installPhase = ''
    runHook preInstall
    # Install the patched cage binary from the upstream tarball…
    install -Dm755 usr/local/bin/cage_xtmapper $out/bin/cage_xtmapper
    # …but install OUR cage_xtmapper.sh (sibling file), not upstream's.
    # Our version is doas-native, has a cleanup trap, a systemd health check
    # for waydroid-container.service, and a boot-wait timeout. See the header
    # of pkgs/cage_xtmapper.sh for the full rationale.
    install -Dm755 ${./cage_xtmapper.sh} $out/bin/cage_xtmapper.sh
    runHook postInstall
  '';

  meta = with lib; {
    description = "Patched cage kiosk compositor that pipes host input to XtMapper for fullscreen Waydroid play";
    homepage = "https://github.com/Xtr126/cage-xtmapper";
    license = licenses.mit;
    platforms = [ "x86_64-linux" ];
    mainProgram = "cage_xtmapper";
  };
}
