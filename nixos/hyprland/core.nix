{ config, pkgs, ... }:
{
  environment.systemPackages = with pkgs; [
    bash
    exa
    fzf
    python39
  ];
}
