{ lib, pkgs, config, ... }:
with lib;
let
  cfg = config.hardware.suspendThenHybernate;
in
{
  options.hardware.suspendThenHybernate = {
    enable = mkEnableOption "Enable custom suspend then hybernate";

    hibernateSeconds = mkOption {
      type = types.int;
      default = 1800;
    };

    hibernateLockFile = mkOption {
      type = types.str;
      default = "/var/run/autohibernate.lock";
    };
  };

  config = mkIf cfg.enable {
    # suspend to RAM (deep) rather than `s2idle`
    boot.kernelParams = [ "mem_sleep_default=deep" ];
    systemd.sleep.extraConfig = ''
      SuspendState=mem
    '';

    systemd.services."awake-after-suspend-for-a-time" = {
      description = "Sets up the suspend so that it'll wake for hibernation";
      wantedBy = [ "suspend.target" ];
      before = [ "systemd-suspend.service" ];
      script = ''
        curtime=$(date +%s)
        echo "$curtime $1" >> /tmp/autohibernate.log
        echo "$curtime" > ${cfg.hibernateLockFile}
        ${pkgs.utillinux}/bin/rtcwake -m no -s ${cfg.hibernateSeconds}
      '';
      serviceConfig.Type = "simple";
    };
    systemd.services."hibernate-after-recovery" = {
      description = "Hibernates after a suspend recovery due to timeout";
      wantedBy = [ "suspend.target" ];
      after = if config.hardware.nvidia.enable then [ "nvidia-resume.service" ] else [ "systemd-suspend.service" ];
      script = ''
        curtime=$(date +%s)
        sustime=$(cat ${cfg.hibernateLockFile})
        rm ${cfg.hibernateLockFile}
        if [ $(($curtime - $sustime)) -ge ${cfg.hibernateSeconds} ] ; then
          systemctl hibernate
        else
          ${pkgs.utillinux}/bin/rtcwake -m no -s 1
        fi
      '';
      serviceConfig.Type = "simple";
    };
  };
}
