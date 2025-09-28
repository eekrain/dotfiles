# overlays/wayland-integration.nix
final: prev: let
  # A curated list of flags for optimal Wayland integration.
  # Based on the document analysis for modern Chromium/Electron versions.
  # Critical fix: --disable-features=WaylandFractionalScaleV1 resolves scaling blurriness
  waylandFlags = [
    "--ozone-platform=wayland"
    "--enable-features=WaylandWindowDecorations,WebRTCPipeWireCapturer,UseOzonePlatform"
    "--gtk-version=4"
    "--enable-wayland-ime"
    "--disable-features=UseChromeOSDirectVideoDecoder,WaylandFractionalScaleV1"
  ];

  # A function to wrap a package with the specified flags.
  wrapWithWaylandFlags = pkg:
    pkg.overrideAttrs (oldAttrs: {
      # Add makeWrapper to the build inputs to make `wrapProgram` available.
      nativeBuildInputs = (oldAttrs.nativeBuildInputs or []) ++ [final.makeWrapper];

      # Add a post-installation hook to wrap the main executable.
      postInstall =
        (oldAttrs.postInstall or "")
        + ''
          for bin in $out/bin/*; do
            # Check if the file is an executable and not a symlink
            if [ -f "$bin" ] && [ -x "$bin" ]; then
              echo "Wrapping executable: $bin"
              wrapProgram "$bin" --add-flags "${builtins.concatStringsSep " " waylandFlags}"
            fi
          done
        '';
    });
in {
  # Apply the wrapper to Visual Studio Code and related editors
  vscode = wrapWithWaylandFlags prev.vscode;
  windsurf = wrapWithWaylandFlags prev.windsurf;
  code-cursor = wrapWithWaylandFlags prev.code-cursor;

  # Apply the wrapper to browsers
  brave = wrapWithWaylandFlags prev.brave;
  ungoogled-chromium = wrapWithWaylandFlags prev.ungoogled-chromium;

  # Apply the wrapper to communication apps
  vesktop = wrapWithWaylandFlags prev.vesktop;
  ferdium = wrapWithWaylandFlags prev.ferdium;
  zoom-us = wrapWithWaylandFlags prev.zoom-us;

  # Additional Chromium-based apps can be added here as needed
  # discord = wrapWithWaylandFlags prev.discord;
  # slack = wrapWithWaylandFlags prev.slack;
  # teams-for-linux = wrapWithWaylandFlags prev.teams-for-linux;
}
