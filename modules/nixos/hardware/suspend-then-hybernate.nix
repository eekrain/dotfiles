{
  config,
  lib,
  pkgs,
  ...
}:
with lib; let
  cfg = config.myModules.hardware;
  hibernateEnvironment = {
    HIBERNATE_SECONDS = toString cfg.suspendThenHybernate.hibernateAfterSuspendSeconds; #30 min after suspend, then do hybernate
    HIBERNATE_LOCK = "/var/run/autohibernate.lock";
  };
in {
  options.myModules.hardware.suspendThenHybernate = {
    enable = mkEnableOption "Enable suspend-then-hybernate configuration";

    hibernateAfterSuspendSeconds = mkOption {
      default = 1800;
      type = types.int;
      description = "Seconds to hibernate after suspend is activated";
    };
  };

  config = mkIf cfg.suspendThenHybernate.enable {
    systemd.services."awake-after-suspend-for-a-time" = {
      description = "Sets up the suspend so that it'll wake for hibernation";
      wantedBy = ["suspend.target"];
      before = ["systemd-suspend.service"];
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
      wantedBy = ["suspend.target"];
      after =
        if (config.myModules.hardware.gpu == "nvidia")
        then ["systemd-suspend.service" "nvidia-resume.service"]
        else ["systemd-suspend.service"];
      environment = hibernateEnvironment;
      script = ''
        curtime=$(date +%s)
        sustime=$(cat $HIBERNATE_LOCK)
        rm $HIBERNATE_LOCK
        if [ $(($curtime - $sustime)) -ge $HIBERNATE_SECONDS ]; then
          sleep 5
          systemctl hibernate
        else
          ${pkgs.utillinux}/bin/rtcwake -m no -s 1
        fi
      '';
      serviceConfig.Type = "simple";
    };
  };
}
