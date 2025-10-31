{
  config,
  lib,
  pkgs,
  ...
}:
with lib; let
  cfg = config.myModules.addons.httpd;
in {
  options.myModules.addons.httpd.enable = mkEnableOption "Enable Apache HTTP server";

  config = mkIf cfg.enable {
    # Enable Apache HTTP server
    services.httpd = {
      enable = true;

      # Basic configuration
      extraModules = ["rewrite" "proxy" "proxy_http"];

      # Default virtual host
      virtualHosts = {
        "localhost" = {
          documentRoot = "/var/www/localhost";
          extraConfig = ''
            DirectoryIndex index.html index.php
            <Directory "/var/www/localhost">
              Options Indexes FollowSymLinks
              AllowOverride All
              Require all granted
            </Directory>
          '';
        };

        "seller-mpp.localhost" = {
          documentRoot = "/var/www/seller-mpp";
          extraConfig = ''
            DirectoryIndex index.html index.php
            <Directory "/var/www/seller-mpp">
              Options Indexes FollowSymLinks
              AllowOverride All
              Require all granted
            </Directory>

            # Proxy configurations
            ProxyPreserveHost On
            ProxyRequests Off

            # Proxy for muatpartsplusglobal app (port 5001)
            ProxyPass /muatpartsplusglobal http://localhost:5001/muatpartsplusglobal
            ProxyPassReverse /muatpartsplusglobal http://localhost:5001/muatpartsplusglobal

            # Proxy for muatpartsplus app (port 4001)
            ProxyPass /muatpartsplus http://localhost:4001/muatpartsplus
            ProxyPassReverse /muatpartsplus http://localhost:4001/muatpartsplus
          '';
        };

        "buyer-mpp.localhost" = {
          documentRoot = "/var/www/buyer-mpp";
          extraConfig = ''
            DirectoryIndex index.html index.php
            <Directory "/var/www/buyer-mpp">
              Options Indexes FollowSymLinks
              AllowOverride All
              Require all granted
            </Directory>

            # Proxy configurations
            ProxyPreserveHost On
            ProxyRequests Off

            # Proxy for muatpartsplusglobal app (port 5002)
            ProxyPass /muatpartsplusglobal http://localhost:5002/muatpartsplusglobal
            ProxyPassReverse /muatpartsplusglobal http://localhost:5002/muatpartsplusglobal

            # Proxy for muatpartsplus app (port 4002)
            ProxyPass /muatpartsplus http://localhost:4002/muatpartsplus
            ProxyPassReverse /muatpartsplus http://localhost:4002/muatpartsplus
          '';
        };
      };
    };

    # Create document root directories
    systemd.tmpfiles.rules = [
      "d /var/www/localhost 0755 root root -"
      "d /var/www/seller-mpp 0755 root root -"
      "d /var/www/buyer-mpp 0755 root root -"
    ];

    # Add Apache to system packages
    environment.systemPackages = with pkgs; [
      apacheHttpd
    ];
  };
}
