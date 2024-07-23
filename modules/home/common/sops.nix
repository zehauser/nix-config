{
  helpers,
  lib,
  osConfig,
  ...
}:
{
  sops = {
    defaultSopsFile = helpers.flakeRoot + /secrets/zhauser.yaml;
    age.keyFile = lib.mkMerge [
      (helpers.mkIfNixos osConfig.sops.secrets."home_manager_sops_keys/zhauser".path)
      (helpers.mkIfMacos "/Users/zhauser/.secrets/sops-age-key-zhauser")
    ];
  };
}
