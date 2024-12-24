# This is your home-manager configuration file
# Use this to configure your home environment (it replaces ~/.config/nixpkgs/home.nix)
{
  inputs,
  outputs,
  lib,
  config,
  pkgs,
  ...
}: {
  # TODO: Set your username
  home = {
    username = "eekrain";
    homeDirectory = "/home/eekrain";
  };
  # TODO: Set your git settings
  programs.git = {
    userName = "Ardian Eka Candra";
    userEmail = "ardianoption@gmail.com";
  };

  # You can import other home-manager modules here
  imports = [
    # If you want to use modules your own flake exports (from modules/home-manager):
    outputs.homeManagerModules.default-settings
    outputs.homeManagerModules.cli
    outputs.homeManagerModules.programs
    outputs.homeManagerModules.addons
    outputs.homeManagerModules.illogical-impulse

    # Or modules exported from other flakes (such as nix-colors):
    # inputs.nix-colors.homeManagerModules.default

    # You can also split up your configuration and import pieces of it here:
    # ./default-settings
  ];

  # Enabling my home manager modules installed
  myHmModules = {
    cli = {
      git = true;
      zsh = true;
      kitty = true;
    };

    programs = {
      bat = true;
      browser = true;
      btop = true;
      easyeffect-audio = true;
      hypridle = true;
      hyprlock = true;
      mimeapps = true;
      motrix = true;
      mpv = true;
      screenshot = true;
      vscode = true;
      wofi = true;
    };

    addons.enable = true;
  };

  # Add stuff for your user as you see fit:
  # programs.neovim.enable = true;
  # home.packages = with pkgs; [ steam ];

  # https://nixos.wiki/wiki/FAQ/When_do_I_update_stateVersion
  home.stateVersion = "24.05";
}
