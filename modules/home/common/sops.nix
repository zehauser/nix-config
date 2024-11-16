{
  config,
  helpers,
  lib,
  osConfig,
  ...
}:
{
  sops = {
    defaultSopsFile = helpers.flakeRoot + /secrets/${config.home.username}.yaml;
    age.keyFile = lib.mkMerge [
      (helpers.mkIfNixos osConfig.sops.secrets."home_manager_sops_keys/${config.home.username}".path)
      (helpers.mkIfMacos "${config.home.homeDirectory}/.secrets/sops-age-key-${config.home.username}")
    ];
  };
}
