{ config, ... }:
{
  # for android development
  programs.adb.enable = true;

  virtualisation.libvirtd.enable = true;
}
