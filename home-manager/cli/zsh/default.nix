{ config, pkgs, ... }:
let
  text = "+_comps";
in
{
  home.packages = with pkgs; [ zinit awscli2 nodejs-16_x yarn nhost-cli ];

  xdg.configFile."zsh/zhist_bkp".source = ./zhist_bkp;

  programs.zsh = {
    enable = true;

    history = {

      size = 10000;
      save = 10000;
    };

    shellAliases = {
      c = "clear";
      rb = "reboot";
      update = "sudo nixos-rebuild switch";
      b-hist = "python ${config.xdg.configHome}/zsh/zhist_bkp/index.py -b -p $HOME/.zsh_history";
      r-hist = "python ${config.xdg.configHome}/zsh/zhist_bkp/index.py -r -p $HOME/.zsh_history";
      kill-gradle = "pkill -f '.*GradleDaemon.*'";
      relog = "sh $HOME/.config/eww/scripts/exitScreenActions.sh logout";
    };

    loginExtra = ''
      python ${config.xdg.configHome}/zsh/zhist_bkp/index.py -b -p $HOME/.zsh_history
    '';

    initExtraBeforeCompInit = ''
      export ZINIT_HOME="${pkgs.zinit}/share/zinit"
      source "''${ZINIT_HOME}/zinit.zsh"
    '';

    # Enable Zi completions
    completionInit = ''
      autoload -Uz _zinit
      (( ''${${text}} )) && _comps[zinit]=_zinit
      autoload bashcompinit && bashcompinit
      autoload -Uz compinit && compinit
    '';


    initExtra = ''
      bindkey -r '^[[A'
      bindkey -r '^[[B'
      function __bind_history_keys() {
        bindkey '^[[A' history-substring-search-up
        bindkey '^[[B' history-substring-search-down
      }
      export ZSH_AUTOSUGGEST_BUFFER_MAX_SIZE=10

      zinit wait lucid light-mode for \
        blockf\
          rupa/z\
          changyuheng/fz\
          andrewferrier/fzf-z\
          changyuheng/zsh-interactive-cd\
        atload'__bind_history_keys'\
          zsh-users/zsh-history-substring-search\
        atload'_zsh_autosuggest_start'\
          zsh-users/zsh-autosuggestions\
        blockf atpull'zinit creinstall -q .'\
          zsh-users/zsh-completions\
        atload'unalias gco gbd gm'\
          davidde/git\
          Schroefdop/git-branches\
          TwoPizza9621536/zsh-exa\
          aubreypwd/zsh-plugin-fd\
        atinit'SHOW_AWS_PROMPT=false'\
          eekrain/zsh-aws\
        atinit'zpcompinit; zpcdreplay'\
          zdharma/fast-syntax-highlighting

      eval "$(${pkgs.starship}/bin/starship init zsh)"
      eval "$(${pkgs.direnv}/bin/direnv hook zsh)"
      
      macchina
    '';
  };
}
