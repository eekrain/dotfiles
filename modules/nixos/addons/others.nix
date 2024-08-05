{
  config,
  inputs,
  pkgs,
  lib,
  ...
}:
with lib; let
  cfg = config.myModules.addons;
in {
  options.myModules.addons = {
    nix-ld = mkEnableOption "Enable nix-ld";
    devenv = mkEnableOption "Enable devenv";
  };

  config = mkMerge [
    (mkIf cfg.nix-ld {
      programs.nix-ld.enable = true;
    })
    {
      environment.systemPackages = with pkgs;
        []
        ++ lib.optionals (cfg.devenv) [
          devenv
          cachix
        ];
    }
  ];
}
