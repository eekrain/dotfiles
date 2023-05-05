{ config, pkgs, ... }:
{
  environment.systemPackages = with pkgs; [
    exa
    fzf
  ];
}
