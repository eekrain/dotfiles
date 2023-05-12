{ config, ... }:
{
  networking.extraHosts =
    ''
      127.0.0.1 mydomain.com
    '';
}
