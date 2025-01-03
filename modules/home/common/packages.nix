{
  helpers,
  lib,
  pkgs,
  ...
}:
let
  packages = with pkgs; {
    common = [
      borgmatic
      cloc
      fd
      file
      jq
      nixfmt-rfc-style
      python312
      python312Packages.ipython
      ripgrep
      screen
      socat
    ];
    mac = [
      _1password-cli
      borgbackup
      ckan
      cowsay
      go_1_23
      minicom
      mosh
      nixos-rebuild
      sops
    ];
    nixos = [
      dtc
      i2c-tools
    ];
  };
in
{
  home.packages = lib.mkMerge [
    packages.common
    (helpers.mkIfMacos packages.mac)
    (helpers.mkIfNixos packages.nixos)
  ];
}
