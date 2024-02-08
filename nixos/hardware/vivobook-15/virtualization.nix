{ config, inputs, pkgs, lib, ... }:
{
  # for android development
  programs.adb.enable = true;

  # Virtual box
  virtualisation.virtualbox.host.enable = true;
  virtualisation.virtualbox.host.package = pkgs.stable.virtualbox;
  virtualisation.virtualbox.host.enableExtensionPack = true;
  users.extraGroups.vboxusers.members = [ "eekrain" ];
}
