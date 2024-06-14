{
  config,
  lib,
  pkgs,
  ...
}:
with lib; let
  cfg = config.myModules.networking;
  proxyUrl = "172.19.0.1:2080";
  proxyType = "socks5";
  proxytoggle = pkgs.writeShellScriptBin "proxytoggle" ''
    running="$(
      doas systemctl status redsocks.service | grep -q inactive
      echo $?
    )"

    if [[ $running == "0" ]]; then
      doas systemctl start firewall.service && doas systemctl start redsocks.service
      notify-send "Proxy activated" "Redsocks proxy is running via ${proxyUrl} with type ${proxyType}" -a 'Shell' -i ${pkgs.my-icons}/share/icons/proxy_enabled.svg
    else
      doas systemctl stop firewall.service && doas systemctl stop redsocks.service
      notify-send "Proxy disabled" "Now internet is accessed without proxy" -a 'Shell' -i ${pkgs.my-icons}/share/icons/proxy_disabled.svg
    fi
  '';
in {
  config = mkIf (cfg.proxyWith == "redsocks") {
    networking.firewall.enable = lib.mkForce true;

    services.redsocks = {
      enable = true;
      log_debug = true;
      log_info = true;
      redsocks = [
        {
          port = 55555;
          proxy = proxyUrl;
          type = proxyType;
          redirectCondition = true;
          redirectInternetOnly = true;
        }
      ];
    };

    environment.systemPackages = [proxytoggle];
  };
}
