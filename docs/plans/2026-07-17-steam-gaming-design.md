# Steam & Gaming on NixOS Hyprland — Design

**Date:** 2026-07-17
**Host:** `eka-laptop` (ASUS Vivobook Pro 15, AMD Cezanne Radeon Vega iGPU + NVIDIA RTX 3050 dGPU)
**Scope:** Add native Steam + gaming tooling to the dotfiles, integrated with the existing `myModules` framework and the AMD/NVIDIA GPU specialisation system.

## Context

The system already handles the hard parts of hybrid-GPU gaming on NixOS:

- Bus IDs are configured: `amdgpuBusId = "PCI:4:0:0"`, `nvidiaBusId = "PCI:1:0:0"` in `modules/nixos/hardware/gpu/amd+nvidia.nix`.
- NVIDIA PRIME offload with `enableOffloadCmd = true` exposes the `nvidia-offload` command.
- A `prefer-nvidia` wrapper (`modules/nixos/hardware/gpu/default.nix`) runs `nvidia-offload "$@"` when available and otherwise falls back to `exec "$@"` — purpose-built for cross-specialisation launchers.
- 32-bit graphics (`hardware.graphics.enable32Bit`) is enabled in both `amd.nix` and `amd+nvidia.nix`.
- GRUB specialisations: `AMD GPU` (default, blacklists nouveau and udev-removes NVIDIA devices for battery life) and `NVIDIA GPU` (force-enables `myModules.hardware.gpu = "amd+nvidia"`).
- Hyprland has `xwayland.enable = true` and windowrules already reference `steam_app_*` and `gamescope` classes.
- A commented-out `# home.packages = with pkgs; [ steam ];` in `home-manager/eekrain.nix` shows an earlier abandoned attempt — the correct path is `programs.steam`.

The **only** missing piece is `programs.steam` and its companion tools. The advice to flat-add Steam/Nvidia blocks into `configuration.nix` would re-enable `hardware.graphics` and re-declare PRIME settings, conflicting with the existing modules.

## Decisions

| Question | Decision |
|---|---|
| Target host | `eka-laptop` (vivobook-15) only |
| Bundle | Steam (core) + mangohud + protonup-qt + gamemode + gamescope (standalone) + protontricks |
| Launch integration | Extra `Steam (NVIDIA)` desktop entry that execs `prefer-nvidia steam` |
| Controllers / wine | Out of scope (YAGNI) |
| Module placement | New `modules/nixos/addons/gaming.nix` following `streaming.nix` pattern |

## Design

### 1. New file: `modules/nixos/addons/gaming.nix`

Defines `mkEnableOption "Enable Steam and gaming tooling"`. When enabled:

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
  });
];
```

**Explicitly NOT re-declared** (already handled elsewhere; adding them would cause merge conflicts):
- `hardware.graphics.enable` / `enable32Bit`
- Any `hardware.nvidia` / PRIME settings
- `programs.hyprland.xwayland.enable`

### 2. Wire-up: `modules/nixos/addons/default.nix`

Append `./gaming.nix` to the `imports` list.

### 3. Enable: `nixos/vivobook-15/configuration.nix`

Add `gaming = true;` to the `myModules.addons` block. Lenovo-kantor stays untouched.

## Runtime Behaviour

| GRUB entry booted | "Steam" icon | "Steam (NVIDIA)" icon |
|---|---|---|
| **AMD GPU** (default) | Steam on iGPU | `prefer-nvidia` finds no `nvidia-offload`, runs plain `steam` on iGPU |
| **NVIDIA GPU** | Steam on iGPU (fine for library browsing) | `prefer-nvidia` calls `nvidia-offload steam`; Steam + child games render on RTX 3050 |

`nvidia-offload` exports `__NV_PRIME_RENDER_OFFLOAD=1`, `__GLX_VENDOR_LIBRARY_NAME=nvidia`, `__VK_LAYER_NV_optimus=NVIDIA_only`, which child processes (games) inherit — so offloaded Steam launches games on the dGPU without per-game launch options. Per-game extras (`mangohud %command%`, `gamemoderun %command%`) can still be appended in Steam's per-title launch options.

## Post-rebuild Game Setup

After `sudo nixos-rebuild switch --flake .#eka-laptop`:

1. Boot into the **NVIDIA GPU** GRUB entry (for RTX 3050 performance).
2. Launch **Steam (NVIDIA)** from the app runner.
3. Install the game; in Library → right-click → Properties → Compatibility → check "Force the use of a specific Steam Play compatibility tool" and pick the latest Proton (or a GE-Proton installed via `protonup-qt`).
4. Optionally append `mangohud %command%` and/or `gamemoderun %command%` to the game's launch options.

## Out of Scope

- Controller drivers (`xpadneo`, `xone`)
- `wine` / `winetricks` for non-Steam Windows games (Proton covers Steam titles)
- `steamtinkerlaunch`
- Enabling gaming on `lenovo-kantor`
