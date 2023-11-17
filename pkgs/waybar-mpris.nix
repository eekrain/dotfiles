{ lib, pkgs, fetchgit, ... }:
pkgs.buildGoModule rec {
  pname = "waybar-mpris";
  version = "485ec0ec0af80a0d63c10e94aebfc59b16aab46b";

  src = fetchgit {
    url = "https://git.hrfee.pw/hrfee/waybar-mpris.git";
    rev = "485ec0ec0af80a0d63c10e94aebfc59b16aab46b";
    fetchSubmodules = false;
    deepClone = false;
    leaveDotGit = false;
    sha256 = "sha256-BjLxWnDNsR2ZnNklNiKzi1DeoPpaZsRdKbVSwNwYhJ4=";
  };

  vendorHash = "sha256-85jFSAOfNMihv710LtfETmkKRqcdRuFCHVuPkW94X/Y=";

  meta = with lib;
    {
      description = "MPRIS2 waybar component";
      homepage = "https://git.hrfee.pw/hrfee/waybar-mpris";
      license = licenses.mit;
      maintainers = with maintainers; [ hrfee ];
    };
}
