{ config, pkgs, ... }:
{
  home.packages = with pkgs; [ awscli2 nodejs_20 nodePackages.pnpm yarn nitch krabby my-turso-cli ];

  xdg.configFile."zsh/zhist_bkp".source = ./zhist_bkp;

  # Add zim zsh plugin manager config here 
  # xdg.configFile."zsh/zimrc".source = ./zimrc;

  programs.zsh = {
    enable = true;
    dotDir = ".config/zsh";

    loginExtra = ''
      hypr_store=$HOME/.config/hypr/store
      mkdir -p $hypr_store
      
      if [ ! -f $hypr_store/dynamic_out.txt ]
      then
        touch $hypr_store/dynamic_out.txt $hypr_store/latest_notif $hypr_store/prev.txt
      fi

      python ${config.xdg.configHome}/zsh/zhist_bkp/index.py -r -p $HOME/.zsh_history
    '';

    logoutExtra = ''
      python ${config.xdg.configHome}/zsh/zhist_bkp/index.py -b -p $HOME/.zsh_history
    '';

    completionInit = ''
      autoload bashcompinit && bashcompinit
    '';

    initExtra = ''
      zstyle ':zim:zmodule' use 'degit'
      ZIM_HOME=~/.config/zsh/.zim
      ZIM_CONFIG_FILE=~/.config/zsh/zimrc

      # Download zimfw plugin manager if missing.
      if [[ ! -e ''${ZIM_HOME}/zimfw.zsh ]]; then
        curl -fsSL --create-dirs -o ''${ZIM_HOME}/zimfw.zsh \
            https://github.com/zimfw/zimfw/releases/latest/download/zimfw.zsh
      fi

      # Install missing modules, and update ''${ZIM_HOME}/init.zsh if missing or outdated.
      if [[ ! ''${ZIM_HOME}/init.zsh -nt ''${ZDOTDIR:-''${HOME}}/.zimrc ]]; then
        source ''${ZIM_HOME}/zimfw.zsh init -q
      fi

      source ''${ZIM_HOME}/init.zsh

      zmodload zsh/terminfo
      [ -n "''${terminfo[kcuu1]}" ] && bindkey "''${terminfo[kcuu1]}" history-substring-search-up
      [ -n "''${terminfo[kcud1]}" ] && bindkey "''${terminfo[kcud1]}" history-substring-search-down
      bindkey '^[[A' history-substring-search-up
      bindkey '^[[B' history-substring-search-down
      
      eval "$(${pkgs.starship}/bin/starship init zsh)"
      nitch
    '';


    shellAliases = {
      c = "clear";
      rb = "reboot";
      update = "sudo nixos-rebuild switch";
      b-hist = "python ${config.xdg.configHome}/zsh/zhist_bkp/index.py -b -p $HOME/.zsh_history";
      r-hist = "python ${config.xdg.configHome}/zsh/zhist_bkp/index.py -r -p $HOME/.zsh_history";
      kill-gradle = "pkill -f '.*GradleDaemon.*'";
      relog = "sh $HOME/.config/eww/scripts/exitScreenActions.sh logout";
      rage = ''mpvpaper -v eDP-1 -o "profile=mpvpaper"'';
      fix-swww = "pkill swww-daemon; rm /run/user/1000/swww.socket; rm -rf ~/.cache/swww/";
      ls = "eza --icons";
      ll = "ls -lbF --git";
      la = "ls -lbhHigmuSa --time-style=long-iso --git --color-scale all";
      lt = "ls --tree --level=2";
      giteka = ''git config user.name "Ardian Eka Candra" && git config user.email "ardianoption@gmail.com"'';
      gitplaton = ''git config user.name "Ardian Eka Candra" && git config user.email "fachri@platon.co.id"'';
    };
  };
}

