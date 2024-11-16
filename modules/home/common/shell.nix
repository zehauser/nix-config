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

  programs.fish.interactiveShellInit = ''
    set -U NIX_CONFIG_REPO ${config.home.homeDirectory}/code/nix-config
  '';

  programs.fish.shellAliases = helpers.mkIfMacos {
    darwin-rebuild = "darwin-rebuild --flake $NIX_CONFIG_REPO#${helpers.machineName}";
  };

  programs.fish.functions = helpers.mkIfMacos {
    nixos-rebuild = {
      argumentNames = [
        "action"
        "machine"
      ];
      body = ''
        command nixos-rebuild  --use-remote-sudo --fast \
          --target-host $machine --build-host alcedo \
          --flake $NIX_CONFIG_REPO#$machine \
          $action $argv[3..]
      '';
    };
  };

  programs.fish.shellAbbrs.temp = helpers.mkIfNixos "sudo ${pkgs.libraspberrypi}/bin/vcgencmd measure_temp";
}
