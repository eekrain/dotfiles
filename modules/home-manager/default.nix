# Add your reusable home-manager modules to this directory, on their own file (https://nixos.wiki/wiki/Module).
# These should be stuff you would like to share with others, not your personal configurations.
{
  # List your module files here
  default-settings = import ./default-settings.nix;
  cli = import ./cli;
  programs = import ./programs;
  addons = import ./addons;
  illogical-impulse = import ./illogical-impulse;
}
