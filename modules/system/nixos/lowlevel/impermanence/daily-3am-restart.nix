{ config, pkgs, ... }:
let
  inherit (builtins) elem;
in
{
  # Restart the machine once daily, to ensure that we wipe / frequently enough that we'll notice sooner rather than
  # later if something that should be on /persistent is not.

  systemd.services.daily-3am-restart = {
    description = "Daily restart at 3 AM Pacific Time";
    serviceConfig = {
      Type = "oneshot";
      ExecStart = "${pkgs.systemdMinimal}/bin/systemctl reboot";
    };
  };

  systemd.timers.daily-3am-restart = {
    description = "Timer to restart system daily at 3 AM Pacific Time";
    wants = [ "time-sync.target" ];
    after = [ "time-sync.target" ];
    wantedBy = [ "timers.target" ];
    timerConfig = {
      OnCalendar = "*-*-* 03:00:00 America/Los_Angeles";
      Persistent = false;
    };
  };

  # This is really important on a system without a realtime clock (like a Raspberry Pi). Otherwise, the
  # daily-3am-restart script may execute *on boot* as the clock "jumps" past 3am. That results in an unbootable system.
  assertions = [
    {
      assertion =
        elem "systemd-time-wait-sync.service" config.systemd.additionalUpstreamSystemUnits
        && elem "multi-user.target" config.systemd.services.systemd-time-wait-sync.wantedBy;
    }
  ];
}
