{
  config,
  helpers,
  lib,
  pkgs,
  ...
}:

{
  home = {
    sessionVariables = {
      EDITOR = "nano";
    };
  };

  programs = {
    fish.enable = true;
  };

  programs.fish.shellInit = lib.mkMerge [
    ''
      set fish_greeting
    ''
    (helpers.mkIfMacos ''
      eval "$(/opt/homebrew/bin/brew shellenv | ${pkgs.gnused}/bin/sed 's/fish_add_path/fish_add_path --append/g')"
      fish_add_path -P /run/current-system/sw/bin
    '')
  ];

  programs.fish.functions = helpers.mkIfMacos {
    borg-run-backup =
      let
        repo = "${pkgs.lib.strings.toLower helpers.machineName}-backup";
      in
      ''
        pushd ~

        read endpoint <"${config.sops.secrets.borg_backup_endpoint.path}"

        env "BORG_PASSPHRASE=op://Personal/borg ${repo} passphrase/password" \
          ${pkgs._1password}/bin/op run -- \
          ${pkgs.borgbackup}/bin/borg --remote-path borg1 create \
          --verbose --progress \
          "$endpoint":${repo}::(date "+%Y-%m-%d")-backup-0 \
          Desktop Documents Downloads files Dropbox
        popd
      '';
  };
  sops.secrets.borg_backup_endpoint = { };

  programs.fish.shellAbbrs.temp = helpers.mkIfNixos "sudo ${pkgs.libraspberrypi}/bin/vcgencmd measure_temp";
}
