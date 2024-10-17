# Custom packages, that can be defined similarly to ones from nixpkgs
# You can build them using 'nix build .#example'
pkgs: {
  # example = pkgs.callPackage ./example { };
  my-custom-font = pkgs.callPackage ./my-custom-font.nix {};
  waybar-mpris = pkgs.callPackage ./waybar-mpris.nix {};
  sddm-sugar-candy = pkgs.callPackage ./sddm-sugar-candy.nix {};
  my-illogical-impulse-dots = pkgs.callPackage ./my-illogical-impulse-dots.nix {};
  my-icons = pkgs.callPackage ./my-icons {};
  materialyoucolor = pkgs.python311Packages.callPackage ./materialyoucolor.nix {};
  responsivelyapp = pkgs.callPackage ./responsivelyapp.nix {};
  zen-browser = pkgs.callPackage ./zen-browser/default.nix {};
  hiddify = pkgs.callPackage ./hiddify/default.nix {};
}
