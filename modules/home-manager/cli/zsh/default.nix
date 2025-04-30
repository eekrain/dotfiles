{
  lib,
  config,
  pkgs,
  ...
}:
with lib; let
  cfg = config.myHmModules.cli;
  starshipCmd = "${config.home.profileDirectory}/bin/starship";
in {
  options.myHmModules.cli.zsh = mkEnableOption "Enable zsh settings";

  config = mkIf cfg.zsh {
    # Addons cli packages
    home.packages = with pkgs; [
      zoxide
      pkgs2411.awscli2
      nitch
      krabby
      turso-cli
      eza
      fzf
      jq
    ];

    # Enable starship promt styling
    programs.starship = {
      enable = true;
      # handle integration myself
      enableZshIntegration = false;
    };
    xdg.configFile."starship.toml".source = ./starship.toml;

    # Add zim zsh plugin manager config here
    xdg.configFile."zsh/zimrc".source = ./zimrc;

    # ZSH settings
    programs.zsh = {
      enable = true;
      # ZSH config dir
      dotDir = ".config/zsh";
      history = {
        path = "${config.xdg.configHome}/zsh/zsh_history";
        save = 1000000000;
        size = 1000000000;
        ignoreAllDups = true;
        ignorePatterns = [
          "pkill *"
          "ga *"
          "gc *"
          "gp *"
          "ls *"
        ];
      };

      initExtra = ''
        setopt INC_APPEND_HISTORY
        setopt HIST_SAVE_NO_DUPS
        setopt HIST_FIND_NO_DUPS

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

        # Enabling history-substring-search binding that's installed in zimrc
        bindkey "^[[A" history-substring-search-up
        bindkey "^[[B" history-substring-search-down

        # Completion styling
        zstyle ':completion:*' matcher-list 'm:{a-z}={A-Za-z}'
        zstyle ':completion:*' list-colors "''${(s.:.)LS_COLORS}"
        zstyle ':completion:*' menu no
        zstyle ':fzf-tab:complete:cd:*' fzf-preview 'eza -1lh --icons --git-ignore --group-directories-first --sort=accessed --color=always $realpath'
        zstyle ':fzf-tab:complete:__zoxide_z:*' fzf-preview 'eza -1lh --icons --git-ignore --group-directories-first --sort=accessed --color=always $realpath'
        zstyle ':fzf-tab:complete:cd:*' fzf-flags --height=35% --preview-window=right:65%
        zstyle ':fzf-tab:complete:__zoxide_z:*' fzf-flags --height=35% --preview-window=right:65%

        if [[ $TERM != "dumb" ]]; then
          eval "$(${starshipCmd} init zsh)"
        fi

        nitch
      '';

      shellAliases = {
        c = "clear";
        rb = "reboot";
        sd = "shutdown now";
        cd = "z";
        wifirescan = "nmcli device wifi rescan";
        ls = "eza --icons";
        ll = "ls -lbF --git";
        la = "ls -lbhHigmuSa --time-style=long-iso --git --color-scale all";
        lt = "ls --tree --level=2";
        # giteka = ''git config user.name "Ardian Eka Candra" && git config user.email "ardianoption@gmail.com"'';
        # gitplaton = ''git config user.name "Ardian Eka Candra" && git config user.email "fachri@platon.co.id"'';
      };
    };

    # Addons variables
    home.sessionVariables = {
      NIXPKGS_ALLOW_UNFREE = "1";
    };
  };
}
