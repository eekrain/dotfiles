{ lib, config, pkgs, ... }:
with lib;
let
  cfg = config.myHmModules.cli;
in
{
  options.myHmModules.cli.zsh = mkEnableOption "Enable zsh settings";

  config = mkIf cfg.zsh {

    # Addons cli packages
    home.packages = with pkgs; [
      awscli2
      nitch
      krabby
      turso-cli
      eza
      fzf
      jq
    ];

    # Enable starship promt styling
    programs.starship.enable = true;
    xdg.configFile."starship.toml".source = ./starship.toml;

    # Add zim zsh plugin manager config here 
    xdg.configFile."zsh/zimrc".source = ./zimrc;

    # ZSH settings
    programs.zsh = {
      enable = true;
      # ZSH config dir
      dotDir = ".config/zsh";

      loginExtra = ''
        hypr_store=$HOME/.config/hypr/store
        mkdir -p $hypr_store
      
        if [ ! -f $hypr_store/dynamic_out.txt ]
        then
          touch $hypr_store/dynamic_out.txt $hypr_store/latest_notif $hypr_store/prev.txt
        fi
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
      
        nitch
      '';

      shellAliases = {
        c = "clear";
        rb = "reboot";
        sd = "shutdown now";
        wifirescan = "nmcli device wifi rescan";
        kill-gradle = "pkill -f '.*GradleDaemon.*'";
        ls = "eza --icons";
        ll = "ls -lbF --git";
        la = "ls -lbhHigmuSa --time-style=long-iso --git --color-scale all";
        lt = "ls --tree --level=2";
        giteka = ''git config user.name "Ardian Eka Candra" && git config user.email "ardianoption@gmail.com"'';
        gitplaton = ''git config user.name "Ardian Eka Candra" && git config user.email "fachri@platon.co.id"'';
      };
    };

    # Addons variables
    home.sessionVariables = {
      NIXPKGS_ALLOW_UNFREE = "1";
    };
  };
}

