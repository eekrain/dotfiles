{
  config,
  inputs,
  pkgs,
  lib,
  ...
}:
with lib;
let
  cfg = config.myModules.addons;
in
{
  options.myModules.addons = {
    android = mkEnableOption "Enable android adb connection";
    docker = mkEnableOption "Enable default docker settings";
    virtualbox = mkEnableOption "Enable default virtualbox settings";
    waydroid = mkEnableOption "Enable default virtualbox settings";
  };

  config = mkMerge [
    (mkIf cfg.android {
      # Install Distrobox and keep Android tools for ADB hardware detection
      # NEEDS DOCKER INSTALLED, ENABLE THE DOCKER OPTION BELOW
      environment.systemPackages = with pkgs; [
        distrobox
        android-tools # Keep this so your host can still talk to physical phones!
      ];

      virtualisation.libvirtd.enable = true; # Optional, but recommended for KVM management
    })

    (mkIf cfg.docker {
      # My default docker settings
      virtualisation.docker.enable = true;
      users.extraGroups.docker.members = [ "eekrain" ];
    })

    (mkIf cfg.virtualbox {
      # Virtual box
      virtualisation.virtualbox.host.enable = true;
      virtualisation.virtualbox.host.package = pkgs.pkgs2605.virtualbox;
      users.extraGroups.vboxusers.members = [ "eekrain" ];
    })

    (mkIf cfg.waydroid {
      virtualisation.waydroid.enable = true;

      # WaydroidSU: CLI Magisk manager/installer for Waydroid.
      # Runtime host tools (lxc-attach, e2fsck, resize2fs, mount/umount)
      # are already injected into wsu's PATH via its wrapper, so only the
      # wsu package itself needs to land on the system here.
      #
      # waydroid-helper: GUI for configuring Waydroid + host-side key/mouse
      # mapper (transparent overlay, F1 to toggle edit/mapping mode). Drawn
      # as an overlay, so under Hyprland it must be floated (see windowrule).
      #
      # cage-xtmapper: patched cage kiosk compositor that pipes host keyboard/
      # mouse events to XtMapper (Android-side mapper) for fullscreen Waydroid
      # gaming. Runs NESTED under Hyprland (Wayland backend) as the regular
      # user; the cage window is fullscreened to get the kiosk effect. Requires
      # the XtMapper APK (xtr.keymapper) installed inside Waydroid.
      #
      # The upstream cage_xtmapper.sh is intricate (Android app_process boot +
      # BOOTCLASSPATH + key-event pipe), so we ship it verbatim from the package
      # and expose a clean `cage-xtmapper` launcher via writeShellScriptBin that
      # only sets PATH (waydroid + cage_xtmapper binary) and execs it.
      environment.systemPackages = with pkgs; [
        wsu
        waydroid-helper
        cage-xtmapper
        (writeShellScriptBin "cage-xtmapper" ''
          export PATH="${lib.makeBinPath [ waydroid pkgs."cage-xtmapper" ]}:$PATH"
          exec "${pkgs."cage-xtmapper"}/bin/cage_xtmapper.sh" "$@"
        '')
      ];
    })
  ];
}
