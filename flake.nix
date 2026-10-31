{
  description = "Your new nix config";

  # Extra cache config
  nixConfig = {
    extra-substituters = [
      "https://cache.nixos.org/"
      "https://nix-community.cachix.org/"
      "https://cache.numtide.com"
      # lantian cache for nix-cachyos-kernel; new URL + key after the
      # Oct 2026 compromise, see issue #110
      "https://cache.lantian.pub/lantian"
      # Official Quickshell cache
      "https://quickshell.cachix.org"
      # Official Hyprland cache
      "https://hyprland.cachix.org"
      "https://claude-code.cachix.org"
      "https://codex-cli.cachix.org"
      "https://install.determinate.systems"
    ];
    extra-trusted-public-keys = [
      "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
      "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
      "niks3.numtide.com-1:DTx8wZduET09hRmMtKdQDxNNthLQETkc/yaX7M4qK0g="
      "lantian:WVGO7vsRMSEN+h7Lp7kv6SAmrkEXgUGbbXm7jMDjBuQ="
      "quickshell.cachix.org-1:1xP1N/G6yWOD6U6vLscZ1F4d62GisE/qez22DUBn2eE="
      "hyprland.cachix.org-1:a7pgxzMz7+chwVL3/pzj6jIBMioiJM7ypFP8PwtkuGc="
      # "hyprland.cachix.org-1:a7pgxzMz7+chwVL3/pzj6jIBMioiJM7ypFP8PwtkuGc="
      "claude-code.cachix.org-1:YeXf2aNu7UTX8Vwrze0za1WEDS+4DuI2kVeWEE4fsRk="
      "codex-cli.cachix.org-1:2+p+8sPX+pH5F1lC6qvAYAUL6SOFD1PTuvTAfD7nmP0="
      "cache.flakehub.com-3:hJuILl5sVK4iKm86JzgdXW12Y2Hwd5G07qKtHTOcDCM="
    ];
  };

  inputs = {
    # Nixpkgs
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

    # You can access packages and modules from different nixpkgs revs
    # at the same time. Here's an working example:
    nixpkgs-2605.url = "github:nixos/nixpkgs/nixos-26.05";
    # Also see the 'packages-2605' overlay at 'overlays/default.nix'.

    # Determinate Nix
    determinate.url = "https://flakehub.com/f/DeterminateSystems/determinate/*";

    # Hyprland flake: day-one releases + hyprland.cachix.org binaries;
    # deliberately NOT following our nixpkgs (cache match requires its own),
    # see https://wiki.hypr.land/nix/cachix/
    hyprland.url = "github:hyprwm/Hyprland";

    # Caelestia desktop environment
    caelestia = {
      # Unpinned: tracks latest so shell + quickshell stay compatible with
      # current Hyprland (Lua-config dispatch API changed in Hyprland 0.5x)
      # NOTE: deliberately NOT following our nixpkgs — caelestia must build
      # against its own locked nixpkgs (as upstream CI does); our unstable
      # broke its cli build (setuptools-scm 9 ignores the unsuffixed
      # SETUPTOOLS_SCM_PRETEND_VERSION the cli package sets)
      url = "github:caelestia-dots/shell";
    };

    # Home manager
    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";

    # TODO: Add any other flake you might need
    # Hardware preconfigured modules from nixos
    hardware.url = "github:nixos/nixos-hardware";
    auto-cpufreq = {
      url = "github:AdnanHodzic/auto-cpufreq";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    zen-browser = {
      url = "github:0xc000022070/zen-browser-flake";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    qylock = {
      url = "git+https://github.com/Darkkal44/qylock";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    # Common Grub2 themes
    grub2-themes = {
      url = "github:vinceliuice/grub2-themes";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    hyprcursor-phinger.url = "github:jappie3/hyprcursor-phinger";

    nix-cachyos-kernel = {
      url = "github:xddxdd/nix-cachyos-kernel/release";
    };

    antigravity-nix = {
      url = "github:jacopone/antigravity-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    codex-manager.url = "github:eekrain/codex-manager";
    bunnix = {
      url = "github:aster-void/bunnix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    llm-agents.url = "github:numtide/llm-agents.nix";
    # open-design.url = "github:nexu-io/open-design";
    codebase-memory-mcp = {
      url = "github:DeusData/codebase-memory-mcp";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nix-vite-plus = {
      url = "github:ryoppippi/nix-vite-plus";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    {
      self,
      nixpkgs,
      home-manager,
      nix-cachyos-kernel,
      hyprcursor-phinger,
      determinate,
      ...
    }@inputs:
    let
      inherit (self) outputs;
      # Supported systems for your flake packages, shell, etc.
      systems = [
        "aarch64-linux"
        "i686-linux"
        "x86_64-linux"
        "aarch64-darwin"
        "x86_64-darwin"
      ];
      # This is a function that generates an attribute by calling a function you
      # pass to it, with each system as an argument
      forAllSystems = nixpkgs.lib.genAttrs systems;
    in
    {
      # Your custom packages
      # Accessible through 'nix build', 'nix shell', etc
      packages = forAllSystems (system: import ./pkgs nixpkgs.legacyPackages.${system});
      # Devshell for bootstrapping
      # Acessible through 'nix develop' or 'nix-shell' (legacy)
      devShells = forAllSystems (
        system:
        let
          pkgs = nixpkgs.legacyPackages.${system};
        in
        import ./shell.nix { inherit pkgs; }
      );
      # Formatter for your nix files, available through 'nix fmt'
      # Other options beside 'alejandra' include 'nixpkgs-fmt'
      formatter = forAllSystems (system: nixpkgs.legacyPackages.${system}.alejandra);

      # Your custom packages and modifications, exported as overlays
      overlays = import ./overlays { inherit inputs; };
      # Reusable nixos modules you might want to export
      # These are usually stuff you would upstream into nixpkgs
      nixosModules = import ./modules/nixos;
      # Reusable home-manager modules you might want to export
      # These are usually stuff you would upstream into home-manager
      homeManagerModules = import ./modules/home-manager;

      # NixOS configuration entrypoint
      # Available through 'nixos-rebuild --flake .#your-hostname'
      nixosConfigurations = {
        # FIXME replace with your hostname
        eka-laptop = nixpkgs.lib.nixosSystem {
          specialArgs = { inherit inputs outputs; };
          modules = [
            determinate.nixosModules.default
            ({ pkgs, ... }: {
              nixpkgs.overlays = [ nix-cachyos-kernel.overlays.pinned ];
            })
            # > Our main nixos configuration file <
            # FIXME replace with your system configuration
            ./nixos/vivobook-15/configuration.nix
          ];
        };

        lenovo-kantor = nixpkgs.lib.nixosSystem {
          specialArgs = { inherit inputs outputs; };
          modules = [
            determinate.nixosModules.default
            ({ pkgs, ... }: {
              nixpkgs.overlays = [ nix-cachyos-kernel.overlays.pinned ];
            })
            # > Our main nixos configuration file <
            # FIXME replace with your system configuration
            ./nixos/lenovo-kantor/configuration.nix
          ];
        };
      };

      # Standalone home-manager configuration entrypoint
      # Available through 'home-manager --flake .#your-username@your-hostname'
      homeConfigurations = {
        # FIXME replace with your username@hostname
        "eekrain@eka-laptop" = home-manager.lib.homeManagerConfiguration {
          pkgs = nixpkgs.legacyPackages.x86_64-linux; # Home-manager requires 'pkgs' instance
          extraSpecialArgs = { inherit inputs outputs; };
          modules = [
            # > Our main home-manager configuration file <
            # FIXME replace with your user spesific configuration
            ./home-manager/eekrain.nix
          ];
        };

        "eekrain@lenovo-kantor" = home-manager.lib.homeManagerConfiguration {
          pkgs = nixpkgs.legacyPackages.x86_64-linux; # Home-manager requires 'pkgs' instance
          extraSpecialArgs = { inherit inputs outputs; };
          modules = [
            # > Our main home-manager configuration file <
            # FIXME replace with your user spesific configuration
            ./home-manager/eekrain.nix
          ];
        };
      };
    };
}
