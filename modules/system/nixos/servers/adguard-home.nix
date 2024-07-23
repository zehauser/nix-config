{
  config,
  helpers,
  lib,
  pkgs,
  ...
}:
let
  settings = {
    schema_version = 28;

    dns = {
      # For other services we want to expose to the tailnet, we generally either:
      # - bind directly to the machine's Tailscale FQDN, or if that's not supported,
      # - bind to 127.0.0.1 and use `tailscale serve` or Caddy as a reverse proxy
      # 
      # AdGuardHome doesn't support binding to a FQDN, and neither `tailscale serve` nor Caddy can act as a reverse
      # proxy for UDP traffic. So instead we'll specify 127.0.0.1 here, but edit the generated config file at runtime
      # to substitute in our Tailscale IPs in the systemd.services.adguardhome.preStart script.
      bind_hosts = [ "127.0.0.1" ];

      safebrowsing_enabled = true;
      ratelimit = 0;

      bootstrap_dns = [
        "1.1.1.1" # Cloudflare
        "9.9.9.9" # Quad9
      ];

      upstream_dns = [
        "https://doh.mullvad.net/dns-query"
        "https://security.cloudflare-dns.com/dns-query"
        "https://dns.quad9.net/dns-query"

        # Try to resolve reverse DNS queries for 100.* IPs with Tailscale DNS, since they are likely to be our tailnet
        # IPs. This helps AdGuardHome auto-discover client names for the query log and statistics.
        "[/*.100.in-addr.arpa/]100.100.100.100"
      ];
    };

    # Some of my current employer's subdomains tend to show up on blocklists. 😬
    user_rules = [
      "@@||grammarly.com^$important"
      "@@||grammarly.net^$important"
      "@@||grammarly.io^$important"
      "@@||grammarlyaws.com^$important"
      "@@||qaqr.io^$important"
      "@@||ppgr.io^$important"
    ];

    statistics.interval = "720h"; # 30 days

    clients.persistent = [
      {
        name = "jhauser-laptop";
        ids = [ "100.69.50.81" ];
        ignore_querylog = true;
      }
      {
        name = "jhauser-phone";
        ids = [ "100.121.96.42" ];
        ignore_querylog = true;
      }
      {
        name = "jhauser-ipad";
        ids = [ "100.102.178.119" ];
        ignore_querylog = true;
      }
    ];

  };
in
{
  services.adguardhome = {
    enable = true;

    host = "127.0.0.1";
    port = helpers.ports.adguardhome.web;

    mutableSettings = false;
    inherit settings;
  };

  modules.caddy.services = lib.mkBefore [
    {
      friendlyName = "DNS";
      privatePort = helpers.ports.adguardhome.web;
    }
  ];

  modules.impermanence.directories = [ "/var/lib/AdGuardHome/data" ];

  systemd.services.adguardhome = {
    after = [ "tailscale-ready.service" ];
    requires = [ "tailscale-ready.service" ];

    preStart = lib.mkAfter ''
      export IPV4_ADDR=$(${config.services.tailscale.package}/bin/tailscale ip -4)
      export IPV6_ADDR=$(${config.services.tailscale.package}/bin/tailscale ip -6)

      if ! [[ "$IPV4_ADDR" =~ ^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
        echo "Invalid IPv4 address: $IPV4_ADDR"
        exit 1
      fi

      # I kind of gave up on this regex. It doesn't really matter anyway — the `tailscale ip` command should error.
      if ! [[ "$IPV6_ADDR" =~ ^[:a-f0-9]+$  ]]; then
        echo "Invalid IPv6 address: $IPV6_ADDR"
        exit 1
      fi

      ${pkgs.yq-go}/bin/yq -i '.dns.bind_hosts = [strenv(IPV4_ADDR), strenv(IPV6_ADDR)]' \
        /var/lib/AdGuardHome/AdGuardHome.yaml
    '';
  };

}
