{ ... }: {
  services.hyprshell = {
    enable = true;
    settings = {
      version = 2;
      windows = {
        switch = {
          switch_workspaces = false;
          modifier = "alt";
        };
      };
    };
  };
}