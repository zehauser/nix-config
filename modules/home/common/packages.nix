{
  helpers,
  lib,
  pkgs,
  ...
}:
let
  packages = with pkgs; {
    common = [
      cloc
      fd
      file
      jq
      nixfmt-rfc-style
      ripgrep
      screen
      socat
    ];
    mac = [
      borgbackup
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
