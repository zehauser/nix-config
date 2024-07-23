{
  # Without this service, on a system without a realtime clock (like a Raspberry Pi), timers may fire unexpectedly on
  # boot as the time "jumps" from something wildly incorrect to the correct time via NTP.
  systemd.additionalUpstreamSystemUnits = [ "systemd-time-wait-sync.service" ];
  systemd.services.systemd-time-wait-sync.wantedBy = [ "multi-user.target" ];
}
