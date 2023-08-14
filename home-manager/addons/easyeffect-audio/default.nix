{ config, ... }:
{
  services.easyeffects = {
    enable = true;
  };

  xdg.configFile."easyeffects/output".source = ./presets;
  xdg.configFile."easyeffects/output".recursive = true;
}
