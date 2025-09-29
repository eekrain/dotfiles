{
  config,
  lib,
  pkgs,
  ...
}: {
  home.packages = [pkgs.rose-pine-hyprcursor pkgs.rose-pine-cursor];

  home.file = {
    # Copy the entire hyprcursors directory
    ".local/share/icons/rose-pine-hyprcursor/hyprcursors" = {
      source = "${pkgs.rose-pine-hyprcursor}/share/icons/rose-pine-hyprcursor/hyprcursors";
      recursive = true; # important for directories
    };

    # Copy the manifest.hl file
    ".local/share/icons/rose-pine-hyprcursor/manifest.hl" = {
      source = "${pkgs.rose-pine-hyprcursor}/share/icons/rose-pine-hyprcursor/manifest.hl";
    };

    ".local/share/icons/rose-pine-cursor" = {
      source = "${pkgs.rose-pine-cursor}/share/icons/BreezeX-RosePine-Linux";
      recursive = true; # important for directories
    };

    # # Also create a symlink with the correct theme name that matches env.conf
    # ".local/share/icons/BreezeX-RoséPine" = {
    #   source = "${pkgs.rose-pine-cursor}/share/icons/BreezeX-RosePine-Linux";
    #   recursive = true; # important for directories
    # };
  };

  home.pointerCursor = {
    gtk.enable = true;
    # x11.enable = true;
    package = pkgs.rose-pine-cursor;
    name = "BreezeX-RoséPine";
    size = 16;
  };

  gtk = {
    enable = true;

    theme = {
      package = pkgs.graphite-gtk-theme.override {
        themeVariants = ["purple"];
        colorVariants = ["dark"];
      };
      name = "Graphite-purple-dark"; # folder inside share/themes
    };

    iconTheme = {
      package = pkgs.qogir-icon-theme;
      name = "Qogir";
    };

    font = {
      name = "Rubik";
      package = pkgs.rubik;
      size = 11;
    };
  };
}
