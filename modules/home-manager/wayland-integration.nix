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

  # Convert flags list to string for desktop entries
  waylandFlagsStr = builtins.concatStringsSep " " waylandFlags;
in {
  options.myHmModules.waylandIntegration = {
    enable = mkEnableOption "Enable Wayland integration for Chromium-based applications";
  };

  config = mkIf cfg.enable {
    # Install the original, unwrapped packages (uses binary cache!)
    home.packages = with pkgs; [
      vscode
      vesktop
      ferdium
      zoom-us
    ];

    # Create overriding desktop entries that launch with Wayland flags
    xdg.desktopEntries = {
      # VSCode
      "code" = {
        name = "Visual Studio Code";
        genericName = "Code Editor";
        comment = "Code Editing. Redefined.";
        exec = "code ${waylandFlagsStr} %F";
        icon = "vscode";
        type = "Application";
        terminal = false;
        categories = ["Development" "IDE"];
        mimeType = ["text/plain" "inode/directory"];
        startupNotify = true;
      };

      # Vesktop
      "vesktop" = {
        name = "Vesktop";
        genericName = "Discord Client";
        comment = "Discord client with Vencord";
        exec = "vesktop ${waylandFlagsStr}";
        icon = "discord";
        type = "Application";
        terminal = false;
        categories = ["Network" "InstantMessaging"];
        startupNotify = true;
      };

      # Ferdium
      "ferdium" = {
        name = "Ferdium";
        genericName = "Messaging App";
        comment = "All your services in one place";
        exec = "ferdium ${waylandFlagsStr}";
        icon = "ferdium";
        type = "Application";
        terminal = false;
        categories = ["Network" "InstantMessaging"];
        startupNotify = true;
      };

      # Zoom
      "zoom" = {
        name = "Zoom";
        genericName = "Video Conferencing";
        comment = "Zoom Video Conferencing";
        exec = "zoom ${waylandFlagsStr}";
        icon = "Zoom";
        type = "Application";
        terminal = false;
        categories = ["Network" "VideoConference"];
        startupNotify = true;
      };
    };
  };
}
