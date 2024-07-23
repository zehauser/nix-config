{
  config,
  helpers,
  lib,
  ...
}:
{
  options.modules.mosquitto.enable = lib.mkEnableOption "mosquitto";

  config = lib.mkIf config.modules.mosquitto.enable {
    systemd.services.mosquitto.requires = [ "tailscale-ready.service" ];
    systemd.services.mosquitto.after = [ "tailscale-ready.service" ];
    services.mosquitto = {
      enable = true;
      listeners = [
        {
          acl = [ "pattern readwrite #" ];
          address = "${helpers.machineName}.myth-bee.ts.net";
          omitPasswordAuth = true;
          port = helpers.ports.mosquitto;
          settings.allow_anonymous = true;
        }
      ];
    };
  };

}
