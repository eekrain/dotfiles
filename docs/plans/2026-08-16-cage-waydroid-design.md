# cage-waydroid — Replace cage-xtmapper with vanilla cage

**Date:** 2026-08-16
**Status:** Approved (option A)
**Repo:** eekrain/dotfiles

## Problem

XtMapper's WASD movement never worked for our games, and after the multi-user
(Account 2) experiments the user games with a controller via mouse-emulated
joystick anyway. XtMapper brings real costs: a patched cage fork, a 230-line
launcher with Android app_process/BOOTCLASSPATH machinery, per-Android-user
install + Magisk root grants, and its overlay is the only thing that draws a
cursor (which is what broke on Account 2).

Without cage (plain waydroid under Hyprland) the mouse can't control the
joystick — verified by the user. So cage stays; XtMapper goes.

## Decision — Option A: vanilla cage from nixpkgs

- The fork's only patch is the XtMapper input pipe; with no XtMapper it is
  dead weight. Use `pkgs.cage` unpatched.
- Delete `pkgs/cage-xtmapper.nix` and `pkgs/cage_xtmapper.sh` entirely.
- Keep the wrapper concept (run/kill/status/help) but rename the command to
  `cage-waydroid` since it no longer involves XtMapper.

## Design

### Command surface

```
cage-waydroid           Launch: health-check waydroid-container.service
                        (reset-failed + restart if needed), stop stale user
                        session, exec cage -- waydroid show-full-ui,
                        cleanup trap stops the session on exit.
cage-waydroid kill      Force teardown (patterns updated: cage/waydroid
                        show-full-ui; no more RemoteServiceShell matches).
cage-waydroid status    Show processes + service state.
cage-waydroid help      Usage text.
```

### What gets deleted (complexity that dies with XtMapper)

- Android boot-wait loop (120s `getprop sys.boot_completed` polling)
- XtMapper APK discovery (`pm path xtr.keymapper...`)
- BOOTCLASSPATH / app_process RemoteServiceShell exec
- `--wayland-client` arg plumbing, `--adb` launch path
- Steam gamescope passthrough env handling (GAMESCOPE_WAYLAND_DISPLAY)

### What stays

- doas-native operation (host uses doas, `permit nopass :wheel`)
- Pre-launch systemd health check for waydroid-container.service
- Stale-session stop + cleanup trap on EXIT/INT/TERM
- Defensive log handling (truncate, remove root-owned/unwritable log)
- Root refusal in the wrapper
- Desktop entry (renamed "Waydroid (Cage Fullscreen)", exec cage-waydroid)

### Log file

`~/.local/state/cage-waydroid.log` (new name, matches new command).

### Companion fix: the cursor (required for Account 2)

Without XtMapper's overlay, the cursor is Android's native pointer — broken
on Account 2. Waydroid's `persist.waydroid.cursor_on_subsurface=true` draws a
software cursor on a subsurface independent of per-user pointer state. Our
earlier attempt failed silently because `waydroid prop set` needs a live
session; this time write it directly into `/var/lib/waydroid/waydroid.cfg`
`[properties]` section, then restart the container. Verify inside a live
session with `waydroid prop get`.

### XtMapper APK disposition

- Uninstall from Account 2 (user 11): `pm uninstall --user 11 xtr.keymapper`
- Leave Account 0's copy installed as dormant fallback; the launcher no
  longer depends on it either way.

### Files touched

- `modules/nixos/addons/virtualization.nix` — new `cage-waydroid` wrapper
  (~40 lines instead of ~150), desktop entry rename, comments updated
- `pkgs/cage-xtmapper.nix` — deleted
- `pkgs/cage_xtmapper.sh` — deleted
- `pkgs/default.nix` — remove cage-xtmapper overlay entry
- Imperative: waydroid.cfg `[properties]` + container restart; APK uninstall
  for user 11

## Testing

1. `nix run`/dry-build the host config; `nh os switch`
2. Launch `cage-waydroid` from terminal (TTY path) and from app launcher
   (no-TTY path → log file)
3. Verify joystick-by-mouse works as before, on Account 1
4. Switch to Account 2: cursor visible, input works
5. `cage-waydroid kill` mid-session → clean teardown, service recovers if
   failed
6. Relaunch after kill → works (no stale session)
