{
  inputs,
  outputs,
  lib,
  config,
  pkgs,
  ...
}: {
  imports = [
    # Adding home manager modules
    # To rebuild home manager settings together with nixos-rebuild
    inputs.home-manager.nixosModules.home-manager
  ];

  # Add home manager settings to rebuild together with nixos-rebuild
  home-manager.extraSpecialArgs = {inherit inputs outputs;};

  #Enabling nix helper for easier nixos-rebuild
  programs.nh = {
    enable = true;
    clean.enable = true;
    clean.extraArgs = "--keep-since 4d --keep 3";
    # Update this programs.nh.flake to your flake dir location, depending on your own machine
    # update it in nixos/machine-name/configuration.nix
    flake = lib.mkDefault "/home/eekrain/dotfiles";
  };

  # Enabling zsh as the default shell
  programs.zsh = {
    enable = true;
    enableBashCompletion = true;
  };

  # Enabling direnv for easier flake development
  programs.direnv.enable = true;
  programs.direnv.nix-direnv.enable = true;

  # Enabling doas for easier sudo access
  security.doas = {
    enable = true;
    extraConfig = ''
      permit nopass :wheel
    '';
  };

  environment.sessionVariables = {
    NIXOS_OZONE_WL = "1";
    ELECTRON_OZONE_PLATFORM_HINT = "wayland";
  };

  # Font configuration
  fonts = {
    packages = with pkgs; [
      # Default fonts
      rubik
      dejavu_fonts
      noto-fonts
      noto-fonts-cjk-sans
      noto-fonts-color-emoji
      liberation_ttf
      material-symbols
      nerd-fonts.jetbrains-mono
      nerd-fonts.caskaydia-mono
      nerd-fonts.caskaydia-cove
      nerd-fonts.fira-code
      nerd-fonts.geist-mono
    ];

    # Font configuration
    fontconfig = {
      defaultFonts = {
        sansSerif = ["Rubik" "DejaVu Sans"];
        serif = ["DejaVu Serif"];
        monospace = ["JetBrainsMono Nerd Font" "DejaVu Sans Mono"];
        emoji = ["Noto Color Emoji"];
      };
    };
  };

  # Default nixpks settings
  nixpkgs = {
    # You can add overlays here
    overlays = [
      # Add overlays your own flake exports (from overlays and pkgs dir):
      outputs.overlays.additions
      outputs.overlays.packages-2605

      # You can also add overlays exported from other flakes:
      # neovim-nightly-overlay.overlays.default

      # Or define it inline, for example:
      # (final: prev: {
      #   hi = final.hello.overrideAttrs (oldAttrs: {
      #     patches = [ ./change-hello-to-hi.patch ];
      #   });
      # })
    ];
    # Configure your nixpkgs instance
    config = {
      # Disable if you don't want unfree packages
      allowUnfree = true;
    };
  };

  # nixos-rebuild-ng fails its test suite under Determinate Nix's long
  # build-dir paths; we switch with nh instead
  system.tools.nixos-rebuild.enable = false;

  # Default nix settings
  nix = let
    flakeInputs = lib.filterAttrs (_: lib.isType "flake") inputs;
    # Opinionated: make flake registry and nix path match flake inputs
    nixPath = lib.mapAttrsToList (n: _: "${n}=flake:${n}") flakeInputs;
  in {
    settings = {
      # Enable flakes and new 'nix' command
      experimental-features = [
        "nix-command"
        "flakes"
      ];
      # Deduplicate and optimize nix store
      auto-optimise-store = true;
      # For using cachix should set trusted user
      trusted-users = ["root" "@wheel" "eekrain"];
      builders-use-substitutes = true;
      # extra substituters to add
      substituters = [
        "https://cache.nixos.org/"
        "https://nix-community.cachix.org/"
        # nix-cachyos-kernel cache; new URL + key after the Oct 2026
        # compromise, see https://github.com/xddxdd/nix-cachyos-kernel/issues/110
        "https://cache.lantian.pub/lantian"
        # Official Quickshell cache
        "https://quickshell.cachix.org"
        # Official Hyprland cache
        "https://hyprland.cachix.org"
      ];
      trusted-public-keys = [
        "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
        "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
        "lantian:WVGO7vsRMSEN+h7Lp7kv6SAmrkEXgUGbbXm7jMDjBuQ="
        "quickshell.cachix.org-1:1xP1N/G6yWOD6U6vLscZ1F4d62GisE/qez22DUBn2eE="
        "hyprland.cachix.org-1:a7pgxzMz7+chwVL3/pzj6jIBMioiJM7ypFP8PwtkuGc="
      ];
      sandbox = false;
      # Opinionated: disable global registry
      flake-registry = "";
      # nix.nixPath is now an alias of this option, so it must be set
      # directly instead of referencing config.nix.nixPath (infinite recursion)
      nix-path = nixPath;
    };
    # Opinionated: disable channels
    channel.enable = false;

    # Opinionated: make flake registry match flake inputs
    registry = lib.mapAttrs (_: flake: {inherit flake;}) flakeInputs;
  };

  # Keep shutdown from sitting on the Nix daemon for too long.
  # Kernel tuning for dev workloads
  boot.kernel.sysctl = {
    # Inotify — high ceilings for file watchers (IDEs, hot-reload, etc.)
    "fs.inotify.max_user_watches" = 2147483647;
    "fs.inotify.max_user_instances" = 8192;

    # Network — wider ephemeral port range + larger TCP buffers
    "net.ipv4.ip_local_port_range" = "1024 65535";
    "net.core.rmem_max" = 16777216;
    "net.core.wmem_max" = 16777216;
    "net.ipv4.tcp_rmem" = "4096 87380 16777216";
    "net.ipv4.tcp_wmem" = "4096 65536 16777216";

    # VM — memory map areas (large JS bundles, Tauri, Rust compilation)
    "vm.max_map_count" = 262144;
    # Faster dirty-page flushing keeps I/O responsive under load
    "vm.dirty_ratio" = 10;
    "vm.dirty_background_ratio" = 5;
  };

  # PAM limits — let user sessions actually use the kernel headroom
  security.pam.loginLimits = [
    { domain = "*"; type = "soft"; item = "nofile"; value = "524288"; }
    { domain = "*"; type = "hard"; item = "nofile"; value = "1048576"; }
  ];
  systemd.services.nix-daemon.serviceConfig.TimeoutStopSec = "10s";
  # NOTE: target the TEMPLATE ("user@"), not a concrete instance like
  # "user@1000". A concrete user@1000.service shadows the real template and
  # ships without ExecStart=, which prevents the user manager from starting —
  # breaking pam_systemd session creation, XDG_RUNTIME_DIR export, and thus
  # SDDM/TTY login into Hyprland.
  systemd.services."user@".serviceConfig.TimeoutStopSec = "10s";
  systemd.user.settings.Manager.DefaultTimeoutStopSec = "10s";
}
