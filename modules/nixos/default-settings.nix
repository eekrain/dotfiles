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
      noto-fonts-emoji
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
      outputs.overlays.modifications
      outputs.overlays.packages-2411
      outputs.overlays.packages-2405

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

  # Default nix settings
  nix = let
    flakeInputs = lib.filterAttrs (_: lib.isType "flake") inputs;
  in {
    settings = {
      # Enable flakes and new 'nix' command
      experimental-features = "nix-command flakes";
      # Deduplicate and optimize nix store
      auto-optimise-store = true;
      # For using cachix should set trusted user
      trusted-users = ["root" "@wheel" "eekrain"];
      builders-use-substitutes = true;
      # extra substituters to add
      substituters = [
        "https://cache.nixos.org"
        "https://nix-community.cachix.org"
        "https://hyprland.cachix.org"
        "https://nixpkgs-wayland.cachix.org"
        "https://nrdxp.cachix.org"
        "https://nix-gaming.cachix.org"
        "https://anyrun.cachix.org"
        "https://nyx.chaotic.cx"
      ];
      trusted-public-keys = [
        "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
        "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
        "hyprland.cachix.org-1:a7pgxzMz7+chwVL3/pzj6jIBMioiJM7ypFP8PwtkuGc="
        "nixpkgs-wayland.cachix.org-1:3lwxaILxMRkVhehr5StQprHdEo4IrE8sRho9R9HOLYA="
        "nrdxp.cachix.org-1:Fc5PSqY2Jm1TrWfm88l6cvGWwz3s93c6IOifQWnhNW4="
        "nix-gaming.cachix.org-1:nbjlureqMbRAxR1gJ/f3hxemL9svXaZF/Ees8vCUUs4="
        "anyrun.cachix.org-1:pqBobmOjI7nKlsUMV25u9QHa9btJK65/C8vnO3p346s="
        "chaotic-nyx.cachix.org-1:HfnXSw4pj95iI/n17rIDy40agHj12WfF+Gqk6SonIT8="
      ];
      sandbox = false;
      # Opinionated: disable global registry
      flake-registry = "";
      # Workaround for https://github.com/NixOS/nix/issues/9574
      nix-path = config.nix.nixPath;
    };
    # Opinionated: disable channels
    channel.enable = false;

    # Opinionated: make flake registry and nix path match flake inputs
    registry = lib.mapAttrs (_: flake: {inherit flake;}) flakeInputs;
    nixPath = lib.mapAttrsToList (n: _: "${n}=flake:${n}") flakeInputs;
  };
}
