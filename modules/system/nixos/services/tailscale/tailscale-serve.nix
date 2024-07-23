{ config, lib, ... }:
{
  options.modules.tailscale = with lib.types; {
    serveTargets = lib.mkOption {
      description = "Local services to expose via the `tailscale serve` feature";
      default = [ ];
      example = [
        [
          {
            publicProtocol = "tcp";
            privateProtocol = "tcp";
            publicPort = ports.service;
            privatePort = ports.service;
          }
        ]
      ];
      type = listOf (submodule {
        options = {
          # We can add more protocols as needed.
          publicProtocol = lib.mkOption { type = enum [ "tcp" ]; };
          publicPort = lib.mkOption { type = port; };
          privateProtocol = lib.mkOption { type = enum [ "tcp" ]; };
          privatePort = lib.mkOption { type = port; };
        };
      });
    };
  };

  config = lib.mkIf (config.modules.tailscale.serveTargets != [ ]) {
    systemd.services.tailscale-serve = {
      after = [ "tailscale-ready.service" ];
      requires = [ "tailscale-ready.service" ];

      serviceConfig.Type = "oneshot";
      serviceConfig.RemainAfterExit = "true";

      script =
        let
          serveCommands = lib.strings.concatLines (
            map (target: ''
              ${config.services.tailscale.package}/bin/tailscale serve --bg \
                --${target.publicProtocol} ${toString target.publicPort} \
                ${target.privateProtocol}://localhost:${toString target.privatePort}
            '') config.modules.tailscale.serveTargets
          );
        in
        ''
          ${config.services.tailscale.package}/bin/tailscale serve reset
          ${serveCommands}
        '';
    };
  };
}
