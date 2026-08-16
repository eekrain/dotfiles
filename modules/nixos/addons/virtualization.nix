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
        # Unified launcher/killer with subcommand dispatch:
        #
        #   cage-xtmapper                       Launch (default subcommand)
        #   cage-xtmapper run [args...]         Launch, forwarding args to script
        #   cage-xtmapper kill                  Forcefully tear down a hung session
        #   cage-xtmapper status                Show what's running
        #   cage-xtmapper help                  Usage
        #
        # The wrapper is defensive about the log file because past `doas
        # cage-xtmapper` invocations left it root-owned (mode 0600), which made
        # the >> redirection fail silently and broke all subsequent appRunner
        # launches (the cage window never appeared).
        (writeShellScriptBin "cage-xtmapper" ''
          set -uo pipefail

          # Refuse root. Running this as root is what polluted the log file
          # ownership in the first place; doas inside the script only escalates
          # individual waydroid calls, not the wrapper itself.
          if [ "$(id -u)" -eq 0 ]; then
            echo "cage-xtmapper must run as your normal user, not root." >&2
            exit 1
          fi

          export PATH="${lib.makeBinPath [ waydroid pkgs."cage-xtmapper" ]}:$PATH"
          LAUNCHER="${pkgs."cage-xtmapper"}/bin/cage_xtmapper.sh"
          LOGFILE="''${XDG_STATE_HOME:-$HOME/.local/state}/cage-xtmapper.log"

          usage() {
            cat <<'EOF'
cage-xtmapper — launch or kill the cage + Waydroid + XtMapper session

Usage:
  cage-xtmapper                 Launch (default subcommand, uses cage)
  cage-xtmapper run [args...]   Launch with cage, forwarding args to cage_xtmapper.sh
                                (e.g. --window-width 1920 --window-height 1080)
  cage-xtmapper kill            Forcefully tear down a hung session
  cage-xtmapper status          Show what's currently running
  cage-xtmapper help            This message
EOF
          }

          do_run() {
            if [ -t 1 ]; then
              # Terminal: stream directly so you see live output.
              exec "$LAUNCHER" "$@"
            else
              # No TTY (appRunner, systemd, etc.): write to a fresh log per launch.
              mkdir -p "$(dirname "$LOGFILE")"
              # Defensive cleanup: if a prior root invocation left the log
              # unwritable, remove it. The parent dir is user-owned, so a
              # normal user can delete root-owned files inside it (no sticky bit).
              if [ -e "$LOGFILE" ] && [ ! -w "$LOGFILE" ]; then
                rm -f "$LOGFILE"
              fi
              # Truncate (>) not append (>>) — one launch's output per file,
              # easier to read than an ever-growing mix of sessions.
              exec "$LAUNCHER" "$@" > "$LOGFILE" 2>&1
            fi
          }

          do_status() {
            echo "[status] cage-xtmapper processes:"
            REMAINING=$(ps -eo pid,user,cmd | grep -iE 'cage_xtmapper|RemoteServiceShell|waydroid show-full-ui|doas waydroid shell' | grep -v grep || true)
            if [ -n "$REMAINING" ]; then
              echo "$REMAINING" | sed 's/^/  /'
            else
              echo "  (clean — no cage/xtmapper processes running)"
            fi
            echo
            echo "[status] waydroid-container.service: $(systemctl is-active waydroid-container.service 2>/dev/null || echo unknown)"
          }

          do_kill() {
            echo "[kill] finding cage-xtmapper processes (excluding systemd container daemon)..."
            # Match cage_xtmapper.sh, the cage_xtmapper binary, the doas waydroid
            # shell wrapper for RemoteServiceShell, and the waydroid show-full-ui
            # subprocess started by cage. EXCLUDE the line that contains
            # `container start` — that's the systemd-managed daemon we must NOT
            # kill. The wrapper itself is named cage-xtmapper (hyphen) so it
            # doesn't match the cage_xtmapper (underscore) pattern — safe.
            PIDS=$(ps -eo pid,cmd | awk '
              /cage_xtmapper/ ||
              /doas waydroid shell/ ||
              /RemoteServiceShell/ ||
              /waydroid show-full-ui/ {
                if ($0 ~ /container start/) next
                if ($0 ~ /awk/) next
                print $1
              }
            ')

            if [ -z "$PIDS" ]; then
              echo "[kill] no cage-xtmapper processes found."
            else
              echo "[kill] tearing down..."
              echo "$PIDS" | while read -r pid; do
                # belt-and-suspenders: never kill PID 1 or ourselves
                [ -z "$pid" ] && continue
                [ "$pid" = "1" ] && continue
                [ "$pid" = "$$" ] && continue
                kill -KILL "$pid" 2>/dev/null && echo "  killed $pid"
              done
            fi

            sleep 1

            # Stop the waydroid user session with a timeout. If it hangs (rare
            # but possible), force-kill the python process by name.
            echo "[kill] stopping waydroid user session..."
            if ! timeout 5 waydroid session stop >/dev/null 2>&1; then
              echo "[kill] session stop hung; force-killing waydroid session python..."
              pkill -KILL -f 'waydroid.py-wrapped session' 2>/dev/null || true
            fi

            # If the systemd service is in 'failed' state (typical after the
            # crashes that led you to run this), reset-failed + restart it so
            # the NEXT cage-xtmapper launch works.
            SERVICE_STATE=$(systemctl is-active waydroid-container.service 2>/dev/null || true)
            if [ "$SERVICE_STATE" != "active" ]; then
              echo "[kill] waydroid-container.service is $SERVICE_STATE; resetting + restarting..."
              doas systemctl reset-failed waydroid-container.service 2>/dev/null || true
              doas systemctl restart waydroid-container.service
              # Brief wait so the daemon registers on D-Bus before the next launch.
              for _ in 1 2 3 4 5 6 7 8 9 10; do
                systemctl is-active --quiet waydroid-container.service && break
                sleep 1
              done
            fi

            echo
            do_status
          }

          # --- Subcommand dispatch ---
          subcommand="''${1:-run}"
          case "$subcommand" in
            run)
              # Drop the explicit "run" if present, then forward remaining args.
              [ "''${1:-}" = "run" ] && shift
              do_run "$@"
              ;;
            kill)
              do_kill
              ;;
            status)
              do_status
              ;;
            help|-h|--help)
              usage
              ;;
            -*)
              # Implicit run with flags (e.g. `cage-xtmapper --window-width 1920`)
              # for backward compatibility with upstream's CLI.
              do_run "$@"
              ;;
            *)
              echo "cage-xtmapper: unknown subcommand '$subcommand'" >&2
              echo >&2
              usage >&2
              exit 1
              ;;
          esac
        '')
        # App-launcher entry so it can be started with no terminal.
        (makeDesktopItem {
          name = "cage-xtmapper";
          desktopName = "Cage XtMapper";
          genericName = "Waydroid fullscreen key mapper";
          comment = "Fullscreen Waydroid with XtMapper keyboard/mouse mapping";
          exec = "cage-xtmapper";
          terminal = false;
          categories = [
            "Game"
            "Utility"
          ];
          icon = "input-gaming";
        })
      ];

      # cage_xtmapper.sh ships as our own script (pkgs/cage_xtmapper.sh),
      # installed by pkgs/cage-xtmapper.nix instead of upstream's. It uses
      # `doas waydroid ...` natively — no sudoers rule needed: doas's global
      # `permit nopass :wheel` (see default-settings.nix) grants eekrain
      # passwordless waydroid access in any context, including cage's nested
      # Wayland session where sudo's NOPASSWD rule was failing.
  })
  ];
}
