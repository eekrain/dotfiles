{ config, lib, pkgs, ... }:
with lib;
let
  cfg = config.myModules.hardware;
  hibernateEnvironment = {
    HIBERNATE_SECONDS = "30";
    HIBERNATE_LOCK = "/var/run/autohibernate.lock";
  };
in
{

  config = mkIf cfg.suspendThenHybernate {
    # suspend to RAM (deep) rather than `s2idle`
    boot.kernelParams = [ "mem_sleep_default=deep" ];
    systemd.sleep.extraConfig = ''
      SuspendState=mem
    '';

    systemd.services."awake-after-suspend-for-a-time" = {
      description = "Sets up the suspend so that it'll wake for hibernation";
      wantedBy = [ "suspend.target" ];
      before = [ "systemd-suspend.service" ];
      environment = hibernateEnvironment;
      script = ''
        curtime=$(date +%s)
        echo "$curtime $1" >> /tmp/autohibernate.log
        echo "$curtime" > $HIBERNATE_LOCK
        ${pkgs.utillinux}/bin/rtcwake -m no -s $HIBERNATE_SECONDS
      '';
      serviceConfig.Type = "simple";
    };
    systemd.services."hibernate-after-recovery" = {
      description = "Hibernates after a suspend recovery due to timeout";
      wantedBy = [ "suspend.target" ];
      after = if (cfg.gpu == "nvidia") then [ "nvidia-resume.service" ] else [ "systemd-suspend.service" ];
      environment = hibernateEnvironment;
      script = ''
        curtime=$(date +%s)
        sustime=$(cat $HIBERNATE_LOCK)
        rm $HIBERNATE_LOCK
        if [ $(($curtime - $sustime)) -ge $HIBERNATE_SECONDS ] ; then
          systemctl hibernate
        else
          ${pkgs.utillinux}/bin/rtcwake -m no -s 1
        fi
      '';
      serviceConfig.Type = "simple";
    };
  };
}
