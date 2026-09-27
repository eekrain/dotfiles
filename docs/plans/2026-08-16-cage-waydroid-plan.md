# cage-waydroid Implementation Plan

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** Replace the cage-xtmapper fork + 230-line XtMapper launcher with a ~60-line `cage-waydroid` wrapper around vanilla nixpkgs cage, plus the waydroid software-cursor fix for Android multi-user.

**Architecture:** One wrapper script (`writeShellScriptBin` in `modules/nixos/addons/virtualization.nix`) health-checks `waydroid-container.service`, stops stale sessions, launches `cage waydroid show-full-ui`, and stops the session on exit via trap. The `pkgs/cage-xtmapper*` files die; `pkgs/default.nix` drops the overlay entry. Imperative side: write `persist.waydroid.cursor_on_subsurface=true` into `/var/lib/waydroid/waydroid.cfg`, restart container, uninstall XtMapper for Android user 11.

**Tech Stack:** NixOS flake repo, `writeShellScriptBin`, `makeDesktopItem`, doas, waydroid/LXC, cage kiosk compositor.

**Design doc:** `docs/plans/2026-08-16-cage-waydroid-design.md`

**Build check command (repo has no test framework):**
```bash
nix build .#nixosConfigurations.eka-laptop.config.system.build.toplevel --dry-run
```

**Git conventions:** short lowercase imperative subject lines (e.g. `update and add gaming with waydroid stuff`).

**Critical implementation gotchas (from debugging history — do not regress):**
1. NO `set -e` in the launch path — waydroid/`session stop` return non-zero for benign reasons; use `|| true` guards. `set -uo pipefail` on the wrapper is fine because cage runs in the foreground (not piped).
2. Do NOT `exec cage ...` — `exec` replaces the shell image and the EXIT cleanup trap never fires. Run cage as the last foreground command instead.
3. The log-file defense (remove unwritable/root-owned log, truncate not append) must survive the rewrite.
4. `waydroid prop set` silently fails when no session is live — that's why we write `waydroid.cfg` directly.

---

### Task 1: Rewrite the wrapper in virtualization.nix

**Files:**
- Modify: `modules/nixos/addons/virtualization.nix` (lines 45–256, the whole `cfg.waydroid` block)

**Step 1: Replace the package set + comment block**

In `modules/nixos/addons/virtualization.nix`, replace everything from the `# WaydroidSU: CLI Magisk manager...` comment through the end of the `makeDesktopItem` closing paren (the whole `environment.systemPackages = with pkgs; [ ... ];` block plus the trailing comment about `cage_xtmapper.sh`) with:

```nix
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
        #
        # Also deliberately no `exec cage ...`: exec replaces the shell
        # image, so the EXIT trap that stops the waydroid session would
        # never fire. cage runs as the last foreground command instead.
        #
        # The wrapper is defensive about the log file because past `doas`
        # invocations left it root-owned (mode 0600), which made the >>
        # redirection fail silently and broke appRunner launches.
        (writeShellScriptBin "cage-waydroid" ''
          set -uo pipefail

          # Refuse root. Running this as root is what polluted the log file
          # ownership in the first place; doas inside the script only
          # escalates individual waydroid calls, not the wrapper itself.
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

            echo "[cage-waydroid] launching cage..." >&2
            cage waydroid show-full-ui
          }

          do_status() {
            echo "[status] cage-waydroid processes:"
            REMAINING=$(ps -eo pid,user,cmd | grep -E 'waydroid show-full-ui|/cage |waydroid.py-wrapped session' | grep -v grep || true)
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
            # Match the cage binary (as /cage followed by space/end — avoids
            # substring hits like "encaged") and the waydroid show-full-ui
            # subprocess cage started. EXCLUDE `container start` — that's the
            # systemd-managed daemon we must NOT kill.
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

            # Stop the waydroid user session with a timeout. If it hangs,
            # force-kill the python process by name.
            echo "[kill] stopping waydroid user session..."
            if ! timeout 5 waydroid session stop >/dev/null 2>&1; then
              echo "[kill] session stop hung; force-killing waydroid session python..."
              pkill -KILL -f 'waydroid.py-wrapped session' 2>/dev/null || true
            fi

            # If the systemd service is in 'failed' state (typical after a
            # hard cage exit), reset-failed + restart it so the NEXT launch
            # works.
            SERVICE_STATE=$(systemctl is-active waydroid-container.service 2>/dev/null || true)
            if [ "$SERVICE_STATE" != "active" ]; then
              echo "[kill] waydroid-container.service is $SERVICE_STATE; resetting + restarting..."
              doas systemctl reset-failed waydroid-container.service 2>/dev/null || true
              doas systemctl restart waydroid-container.service
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
```

Also delete the now-obsolete trailing comment block after the package set (the one starting `# cage_xtmapper.sh ships as our own script (pkgs/cage_xtmapper.sh), ...`).

**Step 2: Dry-build check**

Run: `nix build .#nixosConfigurations.eka-laptop.config.system.build.toplevel --dry-run`
Expected: builds/evaluates clean. If it still references `pkgs."cage-xtmapper"` anywhere, grep fails the build — fix any leftover reference.

**Step 3: Commit**

```bash
git add modules/nixos/addons/virtualization.nix
git commit -m "replace cage-xtmapper with vanilla cage-waydroid wrapper"
```

---

### Task 2: Delete the cage-xtmapper package files

**Files:**
- Delete: `pkgs/cage-xtmapper.nix`
- Delete: `pkgs/cage_xtmapper.sh`
- Modify: `pkgs/default.nix:16`

**Step 1: Remove overlay entry**

In `pkgs/default.nix`, delete the line:
```nix
  cage-xtmapper = pkgs.callPackage ./cage-xtmapper.nix {};
```

**Step 2: Delete the files**

```bash
git rm pkgs/cage-xtmapper.nix pkgs/cage_xtmapper.sh
```

**Step 3: Verify no dangling references**

Run: `rg -n "cage_xtmapper|cage-xtmapper" --hidden -g '!*.md' -g '!flake.lock' .`
Expected: no matches (only docs/*.md may mention it, which is intended history).

**Step 4: Dry-build check**

Run: `nix build .#nixosConfigurations.eka-laptop.config.system.build.toplevel --dry-run`
Expected: clean.

**Step 5: Commit**

```bash
git add -A
git commit -m "drop cage-xtmapper package"
```

---

### Task 3: Imperative host changes (cursor fix + APK cleanup)

These are runtime changes to the live system, not in git.

**Step 1: Write the software-cursor prop into waydroid.cfg**

```bash
grep -n '\[properties\]' /var/lib/waydroid/waydroid.cfg   # confirm section exists
doas sed -i 's/^\[properties\]$/[properties]\npersist.waydroid.cursor_on_subsurface=true/' /var/lib/waydroid/waydroid.cfg
doas grep -A3 '\[properties\]' /var/lib/waydroid/waydroid.cfg
```
Expected: section now contains `persist.waydroid.cursor_on_subsurface=true`.

NOTE: `waydroid prop set persist.waydroid.cursor_on_subsurface true` was tried before and **silently failed** ("WayDroid session is stopped") — writing the cfg directly is the reliable path. The prop is pushed into Android at container start.

**Step 2: Restart the container so the prop takes effect**

```bash
doas systemctl restart waydroid-container.service
```

**Step 3: Uninstall XtMapper from Android user 11 (Account 2) only**

```bash
doas waydroid shell -- sh -c "pm uninstall --user 11 xtr.keymapper"
```
Expected: `Success`. Account 0 (user 0) keeps its copy as dormant fallback.

---

### Task 4: User verification (requires the human)

After `nh os switch`:

1. **TTY path:** run `cage-waydroid` from a terminal → cage window opens fullscreen, Android boots, mouse press-drag drives joystick on Account 1 (same behavior as before).
2. **No-TTY path:** launch "Waydroid (Cage Fullscreen)" from the app launcher → same result; `~/.local/state/cage-waydroid.log` exists and is user-owned.
3. **Account 2 cursor:** switch to Account 2 inside Android → cursor is now VISIBLE (software cursor on subsurface), input works.
4. **Kill:** mid-session run `cage-waydroid kill` → clean teardown, status shows clean.
5. **Relaunch after kill** → works with no stale-session fight.
6. **Exit normally** (close cage / Ctrl-C in TTY) → `waydroid session stop` logged by the trap; relaunch works.

If (3) still shows no cursor, the fallback is investigating `waydroid prop get persist.waydroid.cursor_on_subsurface` from inside a LIVE session (the prop only shows while a session runs) before anything else.

---

### Task 5: Update the debugging history doc

**Files:**
- Modify: `docs/plans/cage-xtmapper-debugging-history.md`

**Step 1: Append Phase 9**

Add a new phase after Phase 8 recording: WASD never worked; multi-user cursor overlay breakage (Magisk per-uid policy insert for user 11 attempted, daemon flaky); decision to remove XtMapper entirely in favor of vanilla cage + Android native pointer + `cursor_on_subsurface`; links to `docs/plans/2026-08-16-cage-waydroid-design.md` and this plan. Update the TL;DR "Current State" to reflect the new architecture (cage-waydroid wrapper, files deleted).

**Step 2: Commit**

```bash
git add docs/plans/
git commit -m "document cage-waydroid migration in debugging history"
```
