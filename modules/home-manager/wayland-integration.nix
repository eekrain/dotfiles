# modules/home-manager/wayland-integration.nix
{
  config,
  lib,
  pkgs,
  ...
}:
with lib; let
  cfg = config.myHmModules.waylandIntegration;

  # Define the same set of Wayland flags as in the system-wide overlay
  # Critical fix: --disable-features=WaylandFractionalScaleV1 resolves scaling blurriness
  waylandFlags = [
    "--ozone-platform=wayland"
    "--enable-features=WaylandWindowDecorations,WebRTCPipeWireCapturer,UseOzonePlatform"
    "--gtk-version=4"
    "--enable-wayland-ime"
    "--disable-features=UseChromeOSDirectVideoDecoder,WaylandFractionalScaleV1"
  ];

  # Create wrapped versions of Chromium-based packages
  wrappedPackages = {
    vscode = pkgs.vscode.overrideAttrs (oldAttrs: {
      nativeBuildInputs = (oldAttrs.nativeBuildInputs or []) ++ [pkgs.makeWrapper];
      postInstall =
        (oldAttrs.postInstall or "")
        + ''
          wrapProgram $out/bin/code --add-flags "${builtins.concatStringsSep " " waylandFlags}"
        '';
    });

    brave = pkgs.brave.overrideAttrs (oldAttrs: {
      nativeBuildInputs = (oldAttrs.nativeBuildInputs or []) ++ [pkgs.makeWrapper];
      postInstall =
        (oldAttrs.postInstall or "")
        + ''
          wrapProgram $out/bin/brave --add-flags "${builtins.concatStringsSep " " waylandFlags}"
        '';
    });

    ungoogled-chromium = pkgs.ungoogled-chromium.overrideAttrs (oldAttrs: {
      nativeBuildInputs = (oldAttrs.nativeBuildInputs or []) ++ [pkgs.makeWrapper];
      postInstall =
        (oldAttrs.postInstall or "")
        + ''
          wrapProgram $out/bin/ungoogled-chromium --add-flags "${builtins.concatStringsSep " " waylandFlags}"
        '';
    });

    vesktop = pkgs.vesktop.overrideAttrs (oldAttrs: {
      nativeBuildInputs = (oldAttrs.nativeBuildInputs or []) ++ [pkgs.makeWrapper];
      postInstall =
        (oldAttrs.postInstall or "")
        + ''
          wrapProgram $out/bin/vesktop --add-flags "${builtins.concatStringsSep " " waylandFlags}"
        '';
    });

    ferdium = pkgs.ferdium.overrideAttrs (oldAttrs: {
      nativeBuildInputs = (oldAttrs.nativeBuildInputs or []) ++ [pkgs.makeWrapper];
      postInstall =
        (oldAttrs.postInstall or "")
        + ''
          wrapProgram $out/bin/ferdium --add-flags "${builtins.concatStringsSep " " waylandFlags}"
        '';
    });

    zoom-us = pkgs.zoom-us.overrideAttrs (oldAttrs: {
      nativeBuildInputs = (oldAttrs.nativeBuildInputs or []) ++ [pkgs.makeWrapper];
      postInstall =
        (oldAttrs.postInstall or "")
        + ''
          wrapProgram $out/bin/zoom --add-flags "${builtins.concatStringsSep " " waylandFlags}"
        '';
    });
  };
in {
  options.myHmModules.waylandIntegration = {
    enable = mkEnableOption "Enable Wayland integration for Chromium-based applications";
  };

  config = mkIf cfg.enable {
    # Override the packages in Home Manager
    home.packages = [
      wrappedPackages.vscode
      wrappedPackages.brave
      wrappedPackages.ungoogled-chromium
      wrappedPackages.vesktop
      wrappedPackages.ferdium
      wrappedPackages.zoom-us
    ];

    # Fix Hyprland-specific geometry bug by managing Chromium Preferences
    # This sets "Use system title bar and borders" which forces a geometry renegotiation
    xdg.configFile = {
      "chromium/Default/Preferences".source = let
        managedPrefs = {
          browser = {
            # This is the equivalent of enabling "Use system title bar and borders"
            # It forces a geometry renegotiation that fixes scaling on Hyprland
            custom_chrome_frame = true;
          };
        };
      in
        (pkgs.formats.json {}).generate "managed-chromium-prefs.json" managedPrefs;
    };
  };
}
