{ config, pkgs, ... }:

{
  home = {
    sessionVariables = {
      LIBSEAT_BACKEND = "logind";
      EDITOR = "nvim";
      BROWSER = "brave";
      TERMINAL = "kitty";
    };
    sessionPath = [
      "$HOME/.local/bin"
      "$HOME/.npm-global/bin"
    ];
  };
}
