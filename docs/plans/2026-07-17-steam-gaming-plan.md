# Steam & Gaming Implementation Plan

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** Add native Steam + gaming tooling to `eka-laptop`, integrated with the existing `myModules.addons` framework and the AMD/NVIDIA specialisation system.

**Architecture:** New `modules/nixos/addons/gaming.nix` defines a `myModules.addons.gaming` toggle that enables `programs.steam`, `programs.gamemode`, and a `Steam (NVIDIA)` desktop entry wrapping `prefer-nvidia steam`. Wire it into `addons/default.nix` and flip the toggle in `vivobook-15/configuration.nix`. Explicitly avoid re-declaring `hardware.graphics` / NVIDIA PRIME (already handled in the GPU modules).

**Tech Stack:** NixOS flake, `programs.steam` NixOS module, `programs.gamemode`, `makeDesktopItem`, existing `prefer-nvidia` wrapper.

**Reference design:** `docs/plans/2026-07-17-steam-gaming-design.md`

---

### Task 1: Create the gaming addon module

**Files:**
- Create: `modules/nixos/addons/gaming.nix`

**Step 1: Write the module**

Mirror the pattern from `modules/nixos/addons/streaming.nix` (single `mkEnableOption`, single `mkIf`).

```nix
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
    gaming = mkEnableOption "Enable Steam and gaming tooling";
  };

  config = mkIf cfg.gaming {
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
      mangohud
      protonup-qt
      gamescope
      (makeDesktopItem {
        name = "steam-nvidia";
        desktopName = "Steam (NVIDIA)";
        exec = "prefer-nvidia steam";
        icon = "steam";
        terminal = false;
        categories = [ "Game" ];
      })
    ];
  };
}
```

**Notes for the engineer:**
- Do NOT add `hardware.graphics.enable` / `enable32Bit` — already declared in `modules/nixos/hardware/gpu/amd.nix` and `amd+nvidia.nix`. Re-declaring causes a "definition conflict" only if values differ, but it's noise — leave it out.
- Do NOT add `programs.hyprland.xwayland.enable` — already in `modules/nixos/desktop/hyprland.nix:123`.
- `makeDesktopItem` is the same pattern used by the existing `cage-xtmapper` entry in `modules/nixos/addons/virtualization.nix:84-96`.
- The `prefer-nvidia` binary is already on `PATH` via `modules/nixos/hardware/gpu/default.nix:32-36`, so the desktop entry's `exec` line resolves correctly.

---

### Task 2: Wire the module into the addons index

**Files:**
- Modify: `modules/nixos/addons/default.nix:8-13`

**Step 1: Add the import**

Append `./gaming.nix` to the `imports` list:

```nix
{
  config,
  lib,
  pkgs,
  ...
}:
with lib; {
  imports = [
    ./virtualization.nix
    ./others.nix
    ./httpd.nix
    ./streaming.nix
    ./gaming.nix
  ];
}
```

---

### Task 3: Enable the module on eka-laptop

**Files:**
- Modify: `nixos/vivobook-15/configuration.nix:65-75` (the `myModules.addons` block)

**Step 1: Flip the toggle**

Add `gaming = true;` to the `addons` block:

```nix
    addons = {
      nix-ld = true;
      devenv = true;
      flatpak = false;
      android = true;
      docker = true;
      virtualbox = false;
      waydroid = true;
      streaming = true;
      httpd.enable = true;
      gaming = true;
    };
```

---

### Task 4: Verify the flake builds

**Step 1: Run flake check (fast, catches option/type errors)**

Run: `nix flake check --no-build .#eka-laptop 2>&1 | tail -50`

If `nix flake check` is too slow or complains about non-nixosConfigurations, substitute:

Run: `nix build .#nixosConfigurations.eka-laptop.config.system.build.toplevel --dry-run 2>&1 | tail -40`

Expected: build plan printed, no eval errors like "option myModules.addons.gaming does not exist" or "infinite recursion".

**Common failures & fixes:**
- `"option myModules.addons.gaming does not exist"` → Task 2 didn't add the import; verify `./gaming.nix` is in `imports`.
- `"infinite recursion encountered"` → likely `config = mkIf cfg.gaming { ... }` referencing itself; double-check the `let cfg = config.myModules.addons;` line is present.
- `makeDesktopItem` not in scope → confirm `with pkgs;` at the top of the config block.

**Step 2: Run a dry-activate (evaluates the full system closure)**

Run: `sudo nixos-rebuild dry-activate --flake .#eka-laptop 2>&1 | tail -40`

Expected: lists services/packages that *would* change (steam, gamemode, gamescope-session), no errors. Look for `would start systemd unit 'steam-systemd-scope'`-style messages or new packages in the diff.

---

### Task 5: Apply the rebuild

**Step 1: Switch**

Run: `sudo nixos-rebuild switch --flake .#eka-laptop 2>&1 | tail -40`

Expected: completes without error; new desktop entries `steam.desktop` and `steam-nvidia.desktop` appear in the application launcher.

**Step 2: Verify desktop entries**

Run: `ls /run/current-system/sw/share/applications/ | grep -E 'steam|gamescope'`

Expected output includes:
```
steam.desktop
steam-nvidia.desktop
```

**Step 3: Verify Steam binary is on PATH**

Run: `command -v steam && steam --version 2>&1 | head -1`

Expected: prints a path like `/run/current-system/sw/bin/steam` and a version line.

**Step 4: Verify gamemode + mangohud + gamescope + protonup-qt are installed**

Run: `for b in gamemoderun mangohud gamescope protonupqt; do command -v $b; done`

Expected: four absolute paths printed, no empty lines.

---

### Task 6: Runtime sanity check on AMD GPU (current boot)

The system is currently booted into the **AMD GPU** specialisation (verified: `lspci` shows only the AMD Cezanne device).

**Step 1: Confirm `prefer-nvidia` falls back gracefully**

Run: `command -v prefer-nvidia && cat "$(command -v prefer-nvidia)"`

Expected: shell script that runs `nvidia-offload "$@"` if available, else `exec "$@"`.

**Step 2: Confirm `nvidia-offload` is NOT on PATH in this specialisation**

Run: `command -v nvidia-offload || echo "not present (expected on AMD GPU boot)"`

Expected: `not present (expected on AMD GPU boot)` — this is correct fallback behaviour, not a bug.

This confirms the "Steam (NVIDIA)" desktop entry will degrade gracefully to plain `steam` when booted into AMD GPU.

---

### Task 7: Document the runtime game-setup steps (optional)

**Files:**
- Modify: `docs/plans/2026-07-17-steam-gaming-design.md` — already contains a "Post-rebuild Game Setup" section. No action needed unless the user asks.

Skip unless the user requests additional docs.

---

### Task 8: Commit (ONLY when user explicitly asks)

The repo's policy is to never auto-commit. When the user asks:

```bash
git add modules/nixos/addons/gaming.nix \
        modules/nixos/addons/default.nix \
        nixos/vivobook-15/configuration.nix \
        docs/plans/2026-07-17-steam-gaming-design.md \
        docs/plans/2026-07-17-steam-gaming-plan.md

git commit -m "feat(nixos): add Steam gaming addon module for eka-laptop"
```

**Commit message style note:** recent commits use the `feat(scope): ...` convention (e.g. `feat(packages): add athas editor and development tools`, `feat(nixos): update desktop environment and power management`). Match that.

---

## Verification Summary (verification-before-completion checklist)

Work is "done" only when **all** of these have actually been run and observed:

- [ ] `nixos-rebuild dry-activate --flake .#eka-laptop` exits 0
- [ ] `nixos-rebuild switch --flake .#eka-laptop` exits 0
- [ ] `/run/current-system/sw/share/applications/steam-nvidia.desktop` exists
- [ ] `steam`, `gamemoderun`, `mangohud`, `gamescope`, `protonupqt` are all on PATH
- [ ] `prefer-nvidia` resolves and shows the fallback script

The dGPU path itself (running a game on the RTX 3050) cannot be verified without a reboot into the **NVIDIA GPU** GRUB specialisation — that's a manual user step after this plan completes, covered in the design doc's "Runtime Behaviour" section.
