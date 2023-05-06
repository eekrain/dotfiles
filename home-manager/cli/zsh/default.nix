{ config, pkgs, ... }:
{
  home.packages = with pkgs; [ zi awscli2 nodejs-16_x yarn nitch krabby ];

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
      rage = ''mpvpaper -v eDP-1 -o "loop profile=mpvpaper"'';
    };

    loginExtra = ''
      python ${config.xdg.configHome}/zsh/zhist_bkp/index.py -b -p $HOME/.zsh_history
    '';

    initExtraBeforeCompInit = ''
      typeset -A ZI
      ZI[HOME_DIR]=$HOME/.zi
      ZI[BIN_DIR]=${pkgs.zi}
      ZI[CACHE_DIR]=$HOME/.cache/zi
      ZI[CONFIG_DIR]=$HOME/.config/zi
      source ${pkgs.zi}/zi.zsh
    '';

    # Enable Zi completions
    completionInit = ''
      autoload -Uz _zi
      (( ''${+_comps} )) && _comps[zi]=_zi
    '';


    initExtra = ''
      bindkey -r '^[[A'
      bindkey -r '^[[B'
      function __bind_history_keys() {
        bindkey '^[[A' history-substring-search-up
        bindkey '^[[B' history-substring-search-down
      }
      export ZSH_AUTOSUGGEST_BUFFER_MAX_SIZE=10
      
      zstyle ":history-search-multi-word" page-size "11"
      zi ice wait lucid
      zi load z-shell/H-S-MW
      
      zi ice atload"unalias gco gbd gm"
      zi light davidde/git

      zinit wait lucid light-mode for \
        rupa/z\
        changyuheng/fz\
        andrewferrier/fzf-z\
        changyuheng/zsh-interactive-cd\
        aubreypwd/zsh-plugin-fd\
        Schroefdop/git-branches\
        TwoPizza9621536/zsh-exa\
        has'zsh-aws' atinit'SHOW_AWS_PROMPT=false'\
          eekrain/zsh-aws

      zi ice wait lucid atload"!_zsh_autosuggest_start"
      zi load zsh-users/zsh-autosuggestions

      # Syntax highlighting
      zi ice wait lucid atinit"ZI[COMPINIT_OPTS]=-C; autoload bashcompinit && bashcompinit; zicompinit; zicdreplay"
      zi light z-shell/F-Sy-H

      eval "$(${pkgs.starship}/bin/starship init zsh)"
      
      nitch
    '';
  };
}
