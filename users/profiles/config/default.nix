{ config, pkgs, ... }:
{
  xdg = {
    enable = true;
    userDirs = {
      enable = true;
      createDirectories = true;
      extraConfig = {
        XDG_SCREENSHOT_DIR = "$HOME/Pictures/Screenshots";
      };
    };

    desktopEntries = {
      whatsapp = {
        name = "WhatsApp";
        genericName = "WhatsApp";
        comment = "WhatsApp Desktop Webapp";
        exec = "chromium --start-maximized --app=https://web.whatsapp.com";
        type = "Application";
        icon = "whatsapp";
        terminal = false;
        startupNotify = true;
        categories = [ "Network" ];
        mimeType = [ "text/plain" ];
        settings = {
          Keywords = "WhatsApp;webapp;";
          X-Ubuntu-Gettext-Domain = "WhatsApp";
          StartupWMClass = "web.whatsapp.com";
        };
      };
    };
  };

  home = {
    pointerCursor = {
      gtk.enable = true;
      x11 = {
        enable = true;
        defaultCursor = "left_ptr";
      };
      # size = 40;
      # package = pkgs.nur.repos.ambroisie.vimix-cursors;
      # name = "Vimix-white-cursors";
      # name = "Vimix-cursors";

      # package = pkgs.capitaine-cursors;
      # name = "capitaine-cursors";

      package = pkgs.nur.repos.ambroisie.volantes-cursors;
      # name = "volantes_light_cursors";
      name = "volantes_cursors";

      # package = pkgs.nur.repos.dan4ik605743.lyra-cursors;
      # name = "LyraF-cursors";
    };
  };

  gtk = {
    enable = true;

    theme = {
      # name = "Numix";
      # package = pkgs.numix-gtk-theme;
      name = "Tokyonight-Dark-B";
      package = pkgs.tokyo-night-gtk-theme;
    };

    cursorTheme = {
      name = "volantes_cursors";
      package = pkgs.nur.repos.ambroisie.volantes-cursors;
    };

    iconTheme = {
      name = "Zafiro-icons";
      package = pkgs.zafiro-icons;
    };

    gtk3.extraConfig = {
      gtk-enable-event-sounds = true;
      gtk-enable-input-feedback-sounds = true;
      gtk-sound-theme-name = "freedesktop";
    };
  };
}
