{ pkgs, ... }:
{
  virtualisation.virtualbox.host.enable = true;
  virtualisation.virtualbox.host.enableExtensionPack = true;
  users.extraGroups.vboxusers.members = [ "eekrain" ];


  # Virtualization
  programs.adb.enable = true;
  virtualisation.libvirtd.enable = true;
  virtualisation.docker.enable = true;


  environment.systemPackages = with pkgs; [ genymotion ];
}
