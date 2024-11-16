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

  programs.fish.shellAbbrs.temp = helpers.mkIfNixos "sudo ${pkgs.libraspberrypi}/bin/vcgencmd measure_temp";
}
