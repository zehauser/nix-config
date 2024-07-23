{ config, ... }:
{
  services.tailscale = {
    enable = true;
    useRoutingFeatures = "both";
    authKeyFile = config.sops.secrets."bootstrap/tailscale_authkey".path;
    extraUpFlags = [
      "--accept-routes"
      "--advertise-exit-node"
      "--ssh"
    ];
  };

  networking.firewall.trustedInterfaces = [ "tailscale0" ];

  modules.impermanence.directories = [ "/var/lib/tailscale" ];

  # This is somewhat ineffective, since these auth keys have a maximum life of 90 days. So if a machine needs to be
  # re-authed to Tailscale, the SOPS secret file probably has to be updated first.
  sops.secrets."bootstrap/tailscale_authkey" = { };
}
