# Custom packages, that can be defined similarly to ones from nixpkgs
# You can build them using 'nix build .#example' or (legacy) 'nix-build -A example'
{ pkgs ? (import ../nixpkgs.nix) { } }: {

  # example = pkgs.callPackage ./example { };
  my-custom-font = pkgs.callPackage ./my-custom-font.nix { };
  waybar-mpris = pkgs.callPackage ./waybar-mpris.nix { };
  sddm-sugar-candy = pkgs.callPackage ./sddm-sugar-candy.nix { };
  freedownloadmanager = pkgs.callPackage ./freedownloadmanager.nix { };
  my-turso-cli = pkgs.callPackage ./my-turso-cli.nix { };
  my-thorium = pkgs.callPackage ./thorium.nix { };
}
