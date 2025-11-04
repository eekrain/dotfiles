{
  config,
  lib,
  pkgs,
  ...
}:
with lib; let
  cfg = config.myModules.hardware;
  # This script is used to prefer the Nvidia GPU when it's available
  preferNvidia = pkgs.writeShellScriptBin "prefer-nvidia" ''
    if command -v nvidia-offload &> /dev/null; then
      nvidia-offload "$@"
    else
      exec "$@"
    fi
  '';
in {
  imports = [
    ./amd.nix
    ./amd+nvidia.nix
  ];

  options.myModules.hardware = {
    gpu = mkOption {
      description = "GPU driver to use";
      type = types.nullOr (types.enum ["amd" "amd+nvidia"]);
      default = null;
    };
  };

  config = mkIf (cfg.gpu != null) {
    environment.systemPackages = with pkgs; [
      mesa-demos
      pciutils
      preferNvidia
    ];
  };
}
