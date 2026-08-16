# cage-xtmapper Debugging History

**Date:** 2026-07-31 onward
**Host:** `eka-laptop` (ASUS Vivobook Pro 15, AMD Cezanne iGPU + NVIDIA RTX 3050 dGPU)
**Goal:** Make `cage-xtmapper` (fullscreen Waydroid + XtMapper key mapping for Android games) work reliably.

This document records the full debugging journey — including wrong hypotheses — so future sessions don't repeat dead ends and so the remaining issue (works after `nh os switch`, fails after reboot) can be picked up with full context.

---

## TL;DR — Current State (as of last edit)

**What works:**
- cage-xtmapper launches, cage window opens, Android boots, XtMapper's RemoteServiceShell starts, key mapping works **provided the user has run `nh os switch` since the last boot**.
- EGL `fd -1` warnings appear in the log — these are **non-fatal Mesa noise** and do not prevent input mapping from working.

**What's broken:**
- After a cold boot, cage-xtmapper's cage window is "not responding" until the user runs `nh os switch` once. Then it works until the next reboot.
- This pattern is consistent and reproducible: `nh os switch` cures it, reboot breaks it.
- Bisect in progress — see "Open Issue" section at the bottom.

**Files touched in this repo:**
- `modules/nixos/addons/gaming.nix` (new) — Steam + gamemode + mangohud + protonup-qt + gamescope + Steam (NVIDIA) desktop entry
- `modules/nixos/addons/default.nix` — wired gaming.nix into imports
- `nixos/vivobook-15/configuration.nix` — enabled `myModules.addons.gaming = true;`
- `modules/nixos/addons/virtualization.nix` — removed sudo extraRules; added cage-xtmapper wrapper with subcommand dispatch (run/kill/status/help) and defensive log handling
- `pkgs/cage-xtmapper.nix` — install our own `cage_xtmapper.sh` instead of upstream's; no more substituteInPlace
- `pkgs/cage_xtmapper.sh` (new) — full rewrite with cleanup trap, systemd health check, boot timeout, doas-native
- `docs/plans/2026-07-17-steam-gaming-design.md` (new) — original design
- `docs/plans/2026-07-17-steam-gaming-plan.md` (new) — implementation plan
- `docs/plans/cage-xtmapper-debugging-history.md` — this file

**Imperative changes applied (not in git):**
- `/var/lib/waydroid/lxc/waydroid/config_nodes` — added two extra mounts:
  ```
  lxc.mount.entry = /dev/dri/card1 dev/dri/card1 none bind,create=file,optional 0 0
  lxc.mount.entry = /dev/dri/card1 dev/dri/card0 none bind,create=file,optional 0 0
  ```
  These were added during wrong-hypothesis debugging (see below) but left in place because they're harmless and might be needed. They survive reboots since the file is persistent.

---

## Chronological History

### Phase 0: Original task — Steam gaming module

User asked to set up Steam and "proper gaming" on NixOS Hyprland. Built a `gaming.nix` addon module:

```nix
programs.steam = {
  enable = true;
  remotePlay.openFirewall = true;
  dedicatedServer.openFirewall = true;
  localNetworkGameTransfers.openFirewall = true;
  gamescopeSession.enable = true;
  protontricks.enable = true;
};
programs.gamemode.enable = true;
environment.systemPackages = with pkgs; [
  mangohud protonup-qt gamescope
  (makeDesktopItem { ... "Steam (NVIDIA)" ... exec = "prefer-nvidia steam"; ... })
];
```

This part was straightforward — verified dry-build clean, user rebuilt, Steam installed correctly. **No GPU/cage issues here.**

### Phase 1: User asked about cage for Steam + Hyprland

User remembered a blog saying cage is good for Steam under Hyprland. We discussed: modern answer is `gamescope` (which we'd already enabled via `gamescopeSession`). Cage-xtmapper is for Android games via Waydroid, not Steam.

User then revealed cage-xtmapper was failing. Began debugging.

### Phase 2: Auth failure — `sudo: a password is required`

**Symptom:** cage-xtmapper log showed hundreds of:
```
sudo: a terminal is required to read the password
sudo: a password is required
```

**Root cause:** `cage_xtmapper.sh` calls `sudo waydroid ...`. The NixOS sudoers rule (`security.sudo.extraRules` in `virtualization.nix`) granted `NOPASSWD: /run/current-system/sw/bin/waydroid` to user `eekrain`. The rule worked in interactive shells but **failed inside cage's nested Wayland session** — likely because cage's process tree is detached from the user's login session in a way that breaks sudo's PAM/group lookup.

**Fix:** Switch to `doas` (the host's actual auth system — `permit nopass :wheel` in `/etc/doas.conf`). Two-part change:

1. **`pkgs/cage-xtmapper.nix`** — added `postInstall` step substituting `sudo waydroid` → `doas waydroid` in the upstream script via `substituteInPlace`.
2. **`modules/nixos/addons/virtualization.nix`** — removed the entire `security.sudo.extraRules` block (no longer needed; `:wheel` rule covers waydroid).

Verified `doas waydroid status` works in any context (TTY, no-TTY, cage). Rebuild fixed the auth failures.

### Phase 3: First "working" session, then crash; post-crash startup failures

User reported cage-xtmapper worked briefly ("played in it for a bit") then crashed. After the crash:
- `waydroid container start` from CLI hung indefinitely
- cage-xtmapper couldn't recover

**Root cause:** cage-xtmapper's systemd-managed `waydroid-container.service` ended up in `failed` state (main PID was killed when cage crashed). In failed state, the daemon doesn't register on D-Bus, and `waydroid container start` from CLI blocks forever trying to talk to it.

**Hypothesis #1 — "stale state from crash"** — proposed that leftover processes / network state from the crash were poisoning the container. Spent significant time killing stale processes, clearing `/run/waydroid-lxc/network_up`, removing `waydroid0` interface, restarting systemd unit. **Result:** Cleanup was needed and we wrote `cage-xtmapper-kill` for it, but it did NOT fix the GPU issue. After fresh boot, cage still failed. **Hypothesis disproven.**

### Phase 4: GPU/EGL `fd -1` — many wrong hypotheses

After Phase 3 cleanup, cage-xtmapper's launch flow worked (container started, Android booted, XtMapper APK found, RemoteServiceShell launched) **but Android UI didn't render**. Log showed:
```
EGL-MAIN: failed to get driver name for fd -1
MESA-LOADER: failed to retrieve device information
/vendor/etc/hwdata/amdgpu.ids: No such file or directory
OpenGLRenderer: Unable to match the desired swap behavior.
```

The cage window opened but was "not responding" — cursor stuck top-left, no rendering.

**Hypothesis #2 — "card1 not mounted in container"** — waydroid's `config_nodes` only mounted `renderD128`, not `card1`. Added imperative mount. **Result:** Didn't fix. Disproven.

**Hypothesis #3 — "card0 not mounted (minigbm looks for card0 first)"** — host has only `card1` (no `card0`); minigbm might default to `card0`. Added imperative mount binding host's `card1` as container's `card0`. **Result:** Didn't fix. Disproven.

**Hypothesis #4 — "switch to swiftshader software rendering"** — set `gpu_mode = swiftshader` in `/var/lib/waydroid/waydroid.cfg` under `[properties]`. **Result:** Config accepted but the running allocator HAL was still `minigbm_gbm_mesa` — waydroid's vendor image dictates which HAL runs, and the config switch didn't take effect. Disproven.

**Hypothesis #5 — "RemoteServiceShell runs as root via app_process, root denied GPU access"** — proposed that the minigbm allocator denies root processes. Never tested because we found a simpler explanation first (Phase 6).

### Phase 5: Isolation test — plain waydroid show-full-ui works

User ran `waydroid show-full-ui` directly (no cage). **Result:** Android UI rendered smoothly. **This isolated cage as the broken variable** — the waydroid container itself was fine; cage's nested compositor was breaking GPU pass-through.

This pointed away from the container config and toward cage itself.

### Phase 6: Wrong conclusion — "drop cage, use direct mode"

Based on Phase 5, I concluded cage itself was broken on the user's stack and proposed a "direct mode" (no cage, plain waydroid show-full-ui + XtMapper in default mode). Implemented:
- Added `--no-cage` flag to `cage_xtmapper.sh`
- Added `direct` subcommand to wrapper
- Added second desktop entry "Waydroid XtMapper (Direct, no cage)"

**Result:** User tested. cage window opened but XtMapper app said "connecting to server..." forever; input didn't work for games.

**The mistake:** I missed that the XtMapper docs explicitly state:
> "Xtmapper works by reading input events directly from event nodes created by the Linux kernel input subsystem... This approach doesn't work for waydroid since host event nodes are not available in the waydroid container."

So XtMapper's default mode (no `--wayland-client`) **cannot receive input on waydroid** — it needs cage (or the deprecated wayland-getevent) to pipe host input in. Direct mode was doomed.

**Reverted:** Removed all the no-cage code (`--no-cage` flag, `direct` subcommand, second desktop entry).

### Phase 7: The actual root cause of the "crash" — my `set -e` regression

User dropped the critical clue: *"the EGL stuff still logs failing, but at least it didnt crash. its not crashing the day YOU created the fix before this (which still uses the patched script instead of our rewrite)"*.

Re-examined: the **old patched script** (just `substituteInPlace sudo→doas`) didn't crash despite the same EGL warnings. The **rewrite** did crash. The difference: my rewrite had `set -euo pipefail` at the top. EGL warnings return non-zero, `set -e` bailed the script, cleanup trap fired, cage window force-closed.

**Realization:** EGL `fd -1` is **non-fatal Mesa noise**. The regular Android UI renders fine despite it (user confirmed with `waydroid show-full-ui`). It only killed my script because of `set -e`. The "GPU bug" I'd been chasing for hours didn't exist as a functional issue — only as log noise.

**Fix:** Removed `set -euo pipefail` from `cage_xtmapper.sh`. Replaced with explicit `set +e` and a comment explaining why (so future-me doesn't re-add it). Updated the header comment to flag this gotcha.

### Phase 8: Open issue — "works after nh os switch, fails after reboot"

After Phase 7, user found the actual remaining bug:

> "it will only working AFTER i ran nh os switch, if i ran nh os switch, reboot, then try to open the cage-xtmapper, it will not responding. BUT, if i ran nh os switch again after reboot, then try to open it again. its working."

Key observations:
- `nh os switch` shows `DIFF: 0 bytes` — no config change, no service restart
- But `> Activating configuration` still runs `/run/current-system/activate`
- Reboot clears whatever state the activate script sets

**Bisect in progress.** Test plan in next reboot's broken state (in order):
1. `doas /run/current-system/activate` — if this alone fixes it, the answer is in activate
2. `doas systemctl restart systemd-logind.service` — refreshes session/seat state
3. `doas systemctl daemon-reload` — what activate always does
4. `doas udevadm trigger --subsystem-match=drm --action=add` — re-trigger DRM device events
5. `id` — verify `render` and `video` groups are present in Hyprland session

Most likely candidates:
- **logind session state** not properly set at cold boot
- **udev** not triggering DRM device permissions at boot
- **Hyprland session** missing supplementary groups until refreshed

Once identified, the fix goes into `cage_xtmapper.sh`'s preflight (with `doas`).

---

## Lessons Learned

1. **EGL/Mesa `fd -1` warnings inside the waydroid container are non-fatal.** Don't chase them as a bug. They appear even when Android UI renders fine. Check whether the cage window is actually responsive before treating them as a problem.

2. **`set -euo pipefail` is wrong for scripts that orchestrate flaky subsystems.** EGL warnings, binder calls, and other "non-zero return but actually fine" patterns will kill the script. Use plain bash defaults for orchestration scripts; reserve `set -e` for tightly-scoped functions.

3. **XtMapper on waydroid requires cage or wayland-getevent** — there is no "direct" path. The docs are explicit: host `/dev/input/event*` isn't in the container, so XtMapper's default mode can't receive input. Don't waste time on no-cage workarounds.

4. **`doas` works in contexts where `sudo`'s PAM path fails.** Specifically: cage's nested Wayland session breaks sudo's group/PAM lookup but doas's simpler model is unaffected. For anything launched from cage-xtmapper, use doas.

5. **waydroid-container.service is `Type=dbus`** — it registers on D-Bus and idles waiting for IPC. The actual LXC container starts on-demand when a user session connects. If the service is in `failed` state, `waydroid container start` from CLI hangs forever. Use `systemctl reset-failed` + `systemctl restart` to recover.

6. **The cage-xtmapper log file at `~/.local/state/cage-xtmapper.log` must be user-owned.** If it ever becomes root-owned (e.g., from a stray `doas cage-xtmapper` invocation, mode 0600), the wrapper's `>> $LOG` redirection silently fails and appRunner launches do nothing. The wrapper now defensively removes non-writable logs and refuses to run as root.

7. **Imperative waydroid LXC config changes survive reboot** (stored in `/var/lib/waydroid/...`), but survive service restart too — `config_nodes` is NOT regenerated by `waydroid-container.service` restart. Confirmed by md5 comparison before/after.

---

## Architecture Summary (final state)

```
cage-xtmapper (wrapper, installed via environment.systemPackages)
├── run [args]            → exec cage_xtmapper.sh (with optional upstream args)
├── kill                  → SIGKILL cage/xtmapper procs + reset waydroid-container if failed
├── status                → show running processes + service state
└── help                  → usage

cage_xtmapper.sh (our rewrite, installed by cage-xtmapper.nix package)
├── Arg parsing           → preserved from upstream verbatim
├── Steam gaming mode     → preserved (GAMESCOPE_WAYLAND_DISPLAY handling)
├── systemd health check  → if waydroid-container.service not active, reset+restart
├── Stop stale session    → waydroid session stop
├── Cleanup trap (EXIT/INT/TERM) → waydroid session stop on exit
├── Find XtMapper APK     → xtr.keymapper[.debug] via doas waydroid shell pm path
└── Launch                → cage_xtmapper waydroid show-full-ui
                          │   (subshell waits for boot, then exec's RemoteServiceShell)
                          └─ RemoteServiceShell receives host input via cage's
                             --wayland-client protocol → maps keys to touch events
```

## Key Files to Read for Context

- `modules/nixos/addons/virtualization.nix` — wrapper definition, kill logic, desktop entry
- `pkgs/cage-xtmapper.nix` — package build (installs cage_xtmapper binary + our cage_xtmapper.sh)
- `pkgs/cage_xtmapper.sh` — our rewrite of the upstream launcher script
- `modules/nixos/default-settings.nix` — `security.doas` config (`permit nopass :wheel`)
- `modules/nixos/hardware/gpu/amd.nix` and `amd+nvidia.nix` — GPU config (bus IDs, PRIME offload, specialisations)

## Useful Runtime Commands

```bash
cage-xtmapper                # launch (default subcommand = run, uses cage)
cage-xtmapper kill           # tear down stuck session cleanly
cage-xtmapper status         # show what's running
cage-xtmapper help           # usage

# Diagnostics
doas tail -50 ~/.local/state/cage-xtmapper.log   # recent launch log
doas waydroid logcat -d | grep -iE 'egl|mesa'    # container-side EGL noise (expected)
systemctl status waydroid-container.service      # daemon health
doas waydroid shell sh -c 'ls -la /dev/dri/'     # GPU visibility inside container
```
