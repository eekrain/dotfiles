{ pkgs, ... }: {
  services.dae.enable = true;
  services.dae.configFile = ./config.dae;
}
