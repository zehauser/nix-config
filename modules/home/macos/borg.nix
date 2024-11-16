{
  config,
  helpers,
  lib,
  pkgs,
  ...
}:
let
  inherit (lib.strings) toLower;
  configFile = ".config/borgmatic/borgmatic-config.yaml";
in
{
  options.modules.borg.enable = lib.mkEnableOption "borg";
  config = lib.mkIf config.modules.borg.enable {
    programs.fish.shellAliases.borgmatic = "borgmatic --config ${config.home.homeDirectory}/${configFile}";

    home.file."${configFile}".text = ''
      source_directories:
        - ${config.home.homeDirectory}/Desktop
        - ${config.home.homeDirectory}/Documents
        - ${config.home.homeDirectory}/Downloads
        - ${config.home.homeDirectory}/Dropbox
        - ${config.home.homeDirectory}/files
        - ${config.home.homeDirectory}/Screenshots
      exclude_caches: true

      repositories:
        - path: ssh://remote-borg-backup/./${toLower helpers.machineName}-backup
      remote_path: borg1

      encryption_passcommand: "${pkgs._1password-cli}/bin/op read 'op://Personal/borg ${helpers.machineName}-backup passphrase/password'"

      keep_within: 2d
      keep_daily: 7
      keep_monthly: 12
      keep_yearly: 100
    '';

    programs.ssh.includes = [ config.sops.secrets.borg_backup_ssh_config.path ];

    sops.secrets.borg_backup_ssh_config = { };
  };
}
