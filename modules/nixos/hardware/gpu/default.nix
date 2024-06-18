{
  config,
  lib,
  pkgs,
  ...
}:
with lib; let
  cfg = config.myModules.hardware;
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
    nvtop = mkEnableOption "Enable nvtop installation";
  };

  config = mkIf cfg.nvtop {
    environment.systemPackages = with pkgs; [
      nvtopPackages.nvidia
    ];
  };
}
