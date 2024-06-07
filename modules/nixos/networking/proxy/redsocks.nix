{ config, lib, pkgs, ... }:
with lib;
let
  cfg = config.myModules.networking;
  proxyscript = pkgs.writeShellScriptBin "proxyscript" ''
    lockfile=/tmp/proxy-status.lock

    if [ "$1" == "check" ]
    then
      stat="$(doas systemctl status redsocks.service | grep -q inactive; echo $?)"
      echo $stat > $lockfile
    elif [ "$1" == "toggle" ]
    then
      if [ "$(cat $lockfile)" == "0" ]
      then
        doas systemctl start firewall.service && doas systemctl start redsocks.service
        echo "1" > $lockfile
        echo "proxy started"
      else
        doas systemctl stop firewall.service && doas systemctl stop redsocks.service
        echo "0" > $lockfile
        echo "proxy stopped"
      fi
    fi
  '';
in
{
  config = mkIf (cfg.proxyWith == "redsocks") {
    networking.firewall.enable = lib.mkForce true;

    services.redsocks = {
      enable = true;
      log_debug = true;
      log_info = true;
      redsocks = [
        {
          port = 55555;
          proxy = "172.19.0.1:2080";
          type = "socks5";
          redirectCondition = true;
          redirectInternetOnly = true;
        }
      ];
    };

    environment.systemPackages = [ proxyscript ];
    environment.shellAliases.toggleproxy = "proxyscript toggle";
  };
}
