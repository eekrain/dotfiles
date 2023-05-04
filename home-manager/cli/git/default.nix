{
  programs = {
    git = {
      enable = true;

      extraConfig = {
        pull.rebase = false;
      };

      userName = "Ardian Eka Candra";
      userEmail = "ardianoption@gmail.com";
    };

    gh.enable = true;
  };
}
