{
  config,
  helpers,
  lib,
  ...
}:
{
  options.modules.calibre.enable = lib.mkEnableOption "calibre";

  config = lib.mkIf config.modules.calibre.enable {
    services.calibre-web = {
      enable = true;

      dataDir = "calibre-web";

      listen = {
        ip = "127.0.0.1";
        port = helpers.ports.calibre-web;
      };

      options = {
        enableBookUploading = true;
        enableBookConversion = true;
        calibreLibrary = "/var/lib/calibre/library";

        reverseProxyAuth = {
          enable = true;
          header = "Calibre-Authenticated-User";
        };
      };
    };

    modules.caddy.services = [
      {
        friendlyName = "Books";
        privatePort = helpers.ports.calibre-web;
        reverseProxyExtraConfig = ''
          header_up Calibre-Authenticated-User admin
          header_down -X-Frame-Options

          # calibre-web sends HSTS headers by default — with max-age of 1 year! Yes, I was surprised too.
          header_down -Strict-Transport-Security
        '';
      }
    ];

    modules.impermanence.directories = [ "/var/lib/calibre/library" ];
  };
}

# I vaguely recall, from much earlier in my NixOS journey, running a bunch of manual commands to adjust directory
# permissions and create the Calibre DB before getting this working. Perhaps I'll return to this sometime and ensure
# the module is able to get calibre-web up and working from scratch.
