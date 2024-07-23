{
  config,
  helpers,
  lib,
  pkgs,
  ...
}:
{
  options.modules.caddy = with lib.types; {
    services = lib.mkOption {
      description = "Local webapps to expose via a Caddy proxy endpoint";
      default = { };
      example = [
        {
          friendlyName = "Books";
          privatePort = ports.calibre-web;
        }
      ];
      type = listOf (submodule {
        options = {
          friendlyName = lib.mkOption {
            description = "Friendly name for the service's tab on the single-pane-of-glass page";
            type = str;
          };
          privatePort = lib.mkOption {
            description = "Local port to proxy to";
            type = port;
          };
          reverseProxyExtraConfig = lib.mkOption {
            description = "Additional Caddy config to add under the reverse_proxy directive";
            default = "";
            type = lines;
          };
        };
      });
    };
  };

  config = lib.mkIf (config.modules.caddy.services != [ ]) (
    let
      inherit (builtins) length listToAttrs toJSON;
      inherit (lib) imap0;
      inherit (lib.attrsets) nameValuePair;

      staticVirtualHosts = {
        "http://".extraConfig = ''
          redir https://${helpers.machineName}.myth-bee.ts.net{uri}
        '';

        "${helpers.machineName}.myth-bee.ts.net".extraConfig = ''
          root * ${singlePaneOfGlassPage.outPath}
          file_server

          # Otherwise, Caddy automatically uses the file mtimes, which in the Nix store is always the Unix epoch!
          header -Last-Modified
        '';
      };

      dynamicVirtualHosts = listToAttrs (
        map (
          {
            publicAddress,
            privatePort,
            reverseProxyExtraConfig,
            ...
          }:
          nameValuePair publicAddress {
            extraConfig = ''
              handle {
                encode gzip zstd
                reverse_proxy localhost:${toString privatePort} {
                  ${reverseProxyExtraConfig}
                }
              }
            '';
          }
        ) services
      );

      singlePaneOfGlassPage =
        pkgs.runCommand "setup-static-server"
          {
            JINJA_VARS = toJSON {
              machineName = helpers.machineName;
              inherit services;
            };
          }
          ''
            mkdir $out
            cp -r ${./single-pane-of-glass-page}/* $out/
            echo "$JINJA_VARS" | ${pkgs.jinja2-cli}/bin/jinja2 --strict $out/index.html.jinja  >$out/index.html 
            rm $out/index.html.jinja
          '';

      services = imap0 (
        index: service:
        service
        // {
          publicAddress = "https://${helpers.machineName}.myth-bee.ts.net:${
            toString (helpers.ports.caddy.dynamicRange.start + index)
          }";
        }
      ) config.modules.caddy.services;
    in
    {
      services.caddy = {
        enable = true;

        # We disable Caddy's default redirect function (and substitute our own, above) because it's convenient to
        # access our server via "https://<bare hostname>", but we need that to redirect to "https://<fqdn of host>"
        # in order to pass certificate verification.
        globalConfig = ''
          default_bind ${helpers.machineName}.myth-bee.ts.net
          auto_https disable_redirects
        '';

        virtualHosts = staticVirtualHosts // dynamicVirtualHosts;
      };

      systemd.services.caddy.requires = [ "tailscale-ready.service" ];
      systemd.services.caddy.after = [ "tailscale-ready.service" ];

      services.tailscale.permitCertUid = "caddy";

      assertions = [
        { assertion = length services <= helpers.ports.caddy.dynamicRange.end - helpers.ports.caddy.dynamicRange.start + 1; }
      ];
    }
  );
}
