{ config, helpers, ... }:
{
  programs.atuin = {
    enable = true;
    enableFishIntegration = true;
    settings = {
      sync_address = "http://alcedo.myth-bee.ts.net:${toString helpers.ports.atuin-server}";
      key_path = config.sops.secrets.atuin_key.path;
      enter_accept = true;
      records = true;
      sync_frequency = 0;
      filter_mode_shell_up_key_binding = "session";
    };
  };

  programs.atuin.settings.db_path = helpers.mkIfNixos "/home/zhauser/.persistent/atuin-history.db";

  sops.secrets.atuin_key = { };
}
