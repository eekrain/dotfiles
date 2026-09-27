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

      # Host↔Waydroid shared folder (~/WaydroidShared ↔ /sdcard/HostShare).
      # NO mounts involved: the container's /data IS the host dir
      # ~/.local/share/waydroid/data (rbind via config_session), so a real
      # directory at data/media/0/HostShare shows in Android as
      # /sdcard/HostShare automatically. ~/WaydroidShared is a symlink to
      # it for host convenience.
      #
      # Why not mounts: host-side fstab binds never propagate into the LXC
      # namespace, and lxc.mount.entry lines get wiped because waydroid
      # regenerates config_session at every session start (verified
      # empirically). Host-side access uses the media_rw group (below).
      # Host access to the share: /data/media is 1023:1023 (media_rw)
      # drwxrwx--- and Android's permission normalizer ACTIVELY resets any
      # chmod we do on those dirs (o+x got wiped within minutes, twice).
      # The stable route is group membership: add the host user to gid 1023
      # so traversal uses Android's own canonical group perms, which are
      # never reset. Requires a re-login to take effect in the session.
      users.groups.media_rw = {
        gid = 1023;
        members = [ "eekrain" ];
      };

      systemd.services."waydroid-hostshare" = {
        description = "Ensure Waydroid HostShare shared directory exists";
        wantedBy = [ "multi-user.target" ];
        before = [ "waydroid-container.service" ];
        serviceConfig = {
          Type = "oneshot";
          RemainAfterExit = true;
        };
        path = [
          pkgs.coreutils
        ];
        script = ''
          DATA=/home/eekrain/.local/share/waydroid/data/media/0
          # Skip silently if waydroid hasn't been initialized yet
          [ -d "$DATA" ] || exit 0
          # Real directory inside Android's /sdcard, writable by the user
          install -d -o eekrain -g users -m 2775 "$DATA/HostShare"
          # Host-side convenience symlink (ln runs as root; fix ownership)
          ln -sfn "$DATA/HostShare" /home/eekrain/WaydroidShared
          chown -h eekrain:users /home/eekrain/WaydroidShared
        '';
      };

      # WaydroidSU: CLI Magisk manager/installer for Waydroid.
      # Runtime host tools (lxc-attach, e2fsck, resize2fs, mount/umount)
      # are already injected into wsu's PATH via its wrapper, so only the
      # wsu package itself needs to land on the system here.
      #
      # waydroid-helper: GUI for configuring Waydroid + host-side key/mouse
      # mapper (transparent overlay, F1 to toggle edit/mapping mode). Drawn
      # as an overlay, so under Hyprland it must be floated (see windowrule).
      #
      # cage-waydroid: launches vanilla cage (kiosk compositor) wrapping
      # `waydroid show-full-ui` fullscreen. Android sees the mouse as its
      # native pointer, so press-drag controls game joysticks directly —
      # no XtMapper needed. The old cage-xtmapper fork existed only to pipe
      # host input to XtMapper's RemoteServiceShell; it was removed after
      # WASD mapping proved unusable and its overlay was the only cursor
      # source (broken on Android multi-user). See
      # docs/plans/cage-xtmapper-debugging-history.md.
      environment.systemPackages = with pkgs; [
        wsu
        waydroid-helper
        # Unified launcher with subcommand dispatch:
        #
        #   cage-waydroid                       Launch (default subcommand)
        #   cage-waydroid run                   Same as default (compat)
        #   cage-waydroid kill                  Forcefully tear down a hung session
        #   cage-waydroid status                Show what's running
        #   cage-waydroid help                  Usage
        #
        # Deliberately NO set -e in the launch path: waydroid emits
        # non-fatal non-zero returns (EGL warnings, "session is stopped")
        # that would abort the script and force-close the cage window —
        # regression documented in cage-xtmapper-debugging-history.md.
        # Also no `exec cage ...`: exec replaces the shell image, so the
        # EXIT trap stopping the waydroid session would never fire; cage
        # runs as the last foreground command instead.
        #
        # The wrapper is defensive about the log file because past `doas`
        # invocations left it root-owned (mode 0600), which made the >>
        # redirection fail silently and broke appRunner launches.
        (writeShellScriptBin "cage-waydroid" ''
          set -uo pipefail

          # Refuse root. Running this as root is what polluted the log file
          # ownership in the first place; doas inside the script only escalates
          # individual waydroid calls, not the wrapper itself.
          if [ "$(id -u)" -eq 0 ]; then
            echo "cage-waydroid must run as your normal user, not root." >&2
            exit 1
          fi

          export PATH="${lib.makeBinPath [ waydroid pkgs.cage ]}:$PATH"
          LOGFILE="''${XDG_STATE_HOME:-$HOME/.local/state}/cage-waydroid.log"

          usage() {
            cat <<'EOF'
cage-waydroid — launch or kill the cage + Waydroid fullscreen session

Usage:
  cage-waydroid        Launch fullscreen Waydroid inside cage (default)
  cage-waydroid run    Same as default (compat subcommand)
  cage-waydroid kill   Forcefully tear down a hung session
  cage-waydroid status Show what's currently running
  cage-waydroid help   This message
EOF
          }

          do_run() {
            # Pre-launch systemd health check. After a hard cage crash,
            # waydroid-container.service can sit in 'failed' state where the
            # daemon never re-registers on D-Bus and `waydroid container
            # start` hangs forever. Detect and recover.
            if ! systemctl is-active --quiet waydroid-container.service 2>/dev/null; then
              echo "[cage-waydroid] waydroid-container.service not active; resetting + restarting..." >&2
              doas systemctl reset-failed waydroid-container.service 2>/dev/null || true
              doas systemctl restart waydroid-container.service || true
              for _ in 1 2 3 4 5 6 7 8 9 10; do
                systemctl is-active --quiet waydroid-container.service && break
                sleep 1
              done
            fi

            # Stop any stale user session from a previous run (idempotent).
            echo "[cage-waydroid] stopping any stale waydroid user session..." >&2
            waydroid session stop >/dev/null 2>&1 || true

            # Cleanup trap: when cage exits (window closed, crash, Ctrl-C,
            # SIGTERM), stop the waydroid user session so the NEXT launch
            # starts clean. We deliberately do NOT touch
            # waydroid-container.service here — that's systemd-managed.
            cleanup() {
              echo "[cage-waydroid] cleaning up waydroid user session..." >&2
              waydroid session stop >/dev/null 2>&1 || true
            }
            trap cleanup EXIT INT TERM

            # Ensure the container is running (idempotent — safe if up).
            echo "[cage-waydroid] ensuring waydroid container is running..." >&2
            doas waydroid container start >/dev/null 2>&1 || true

            # Foreground (NOT exec — the EXIT trap must survive to fire).
            echo "[cage-waydroid] launching cage..." >&2
            cage waydroid show-full-ui
          }

          do_status() {
            echo "[status] cage-waydroid processes:"
            REMAINING=$(ps -eo pid,user,cmd | grep -E 'waydroid show-full-ui|/cage( |$)|waydroid.py-wrapped session' | grep -v grep || true)
            if [ -n "$REMAINING" ]; then
              echo "$REMAINING" | sed 's/^/  /'
            else
              echo "  (clean — no cage/waydroid processes running)"
            fi
            echo
            echo "[status] waydroid-container.service: $(systemctl is-active waydroid-container.service 2>/dev/null || echo unknown)"
          }

          do_kill() {
            echo "[kill] finding cage-waydroid processes (excluding systemd container daemon)..."
            # Match the cage binary (/cage followed by space or end of line —
            # avoids substring hits like "encaged") and the waydroid
            # show-full-ui subprocess cage started. EXCLUDE the line that
            # contains `container start` — that's the systemd-managed daemon
            # we must NOT kill.
            PIDS=$(ps -eo pid,cmd | awk '
              /waydroid show-full-ui/ || /\/cage( |$)/ {
                if ($0 ~ /container start/) next
                if ($0 ~ /awk/) next
                print $1
              }
            ')

            if [ -z "$PIDS" ]; then
              echo "[kill] no cage-waydroid processes found."
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

            # If the systemd service is in 'failed' state (typical after a
            # hard cage exit), reset-failed + restart it so the NEXT
            # cage-waydroid launch works.
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
              [ "''${1:-}" = "run" ] && shift
              if [ -t 1 ]; then
                # Terminal: stream directly so you see live output.
                do_run
              else
                # No TTY (appRunner, systemd, etc.): write to a fresh log
                # per launch.
                mkdir -p "$(dirname "$LOGFILE")"
                # Defensive cleanup: if a prior root invocation left the
                # log unwritable, remove it. The parent dir is user-owned,
                # so a normal user can delete root-owned files inside it.
                if [ -e "$LOGFILE" ] && [ ! -w "$LOGFILE" ]; then
                  rm -f "$LOGFILE"
                fi
                # Truncate (>) not append (>>) — one launch's output per file.
                do_run > "$LOGFILE" 2>&1
              fi
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
            *)
              echo "cage-waydroid: unknown subcommand '$subcommand'" >&2
              echo >&2
              usage >&2
              exit 1
              ;;
          esac
        '')
        # App-launcher entry so it can be started with no terminal.
        (makeDesktopItem {
          name = "cage-waydroid";
          desktopName = "Waydroid (Cage Fullscreen)";
          genericName = "Waydroid fullscreen gaming";
          comment = "Fullscreen Waydroid in a cage kiosk compositor; mouse drives Android pointer";
          exec = "cage-waydroid";
          terminal = false;
          categories = [
            "Game"
            "Utility"
          ];
          icon = "input-gaming";
        })
      ];
  })
  ];
}
