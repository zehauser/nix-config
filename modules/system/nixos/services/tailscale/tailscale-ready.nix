{ config, pkgs, ... }:
{
  # We can probably delete this if https://github.com/tailscale/tailscale/issues/11504 is fixed.
  systemd.services.tailscale-ready = {
    description = "Wait until Tailscale IP is available";

    after = [ "tailscaled.service" ];
    requires = [ "tailscaled.service" ];

    serviceConfig.Type = "oneshot";
    serviceConfig.RemainAfterExit = "true";

    script =
      let
        checkScript = pkgs.writeShellScript "tailscale-ip-ready" ''
          IPV4_ADDR=$(${config.services.tailscale.package}/bin/tailscale ip -4 || echo 0)
          [[ "$IPV4_ADDR" =~ ^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+$ ]]
          exit $?
        '';
      in
      ''
        echo "Waiting for Tailscale to get an IP address..."
        ${pkgs.retry}/bin/retry -d 1 -t 25 -- ${checkScript}
      '';
  };
}
