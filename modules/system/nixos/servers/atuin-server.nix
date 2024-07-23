{
  config,
  helpers,
  lib,
  ...
}:
{
  options.modules.atuin-server.enable = lib.mkEnableOption "atuin-server";

  config = lib.mkIf config.modules.atuin-server.enable {
    services.atuin = {
      enable = true;
      # current atuin version requires this to be an IP address, rather than a hostname, so we'll bind locally and
      # expose via tailscale serve.
      host = "127.0.0.1";
      port = helpers.ports.atuin-server;
      openRegistration = false;
    };

    modules.tailscale.serveTargets = [
      {
        publicProtocol = "tcp";
        privateProtocol = "tcp";
        publicPort = helpers.ports.atuin-server;
        privatePort = helpers.ports.atuin-server;
      }
    ];
  };
}

# Self-hosting Atuin was not purely declarative — there was some annoying one-time setup here due to features which
# would make sense if you were running a multi-user server and it was exposed to the public internet, neither of which
# is true here:
# - temporarily set `services.atuin.openRegistration = true`
# - Run `atuin register -u ... -e ...` (and set password)
# - turn `services.atuin.openRegistration` back off
# - run `atuin key` and use that for the SOPS key (used in home-manager)
#
# It would be nice to be able to specify a list of users, keys, and passwords upfront. Maybe I'll make a PR someday.
