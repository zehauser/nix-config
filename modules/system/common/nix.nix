{
  helpers,
  lib,
  pkgs,
  ...
}:
helpers.mkCrossPlatformModule {
  nix = {
    settings = {
      experimental-features = [
        "nix-command"
        "flakes"
        "repl-flake"
      ];
    };
  };

  nixpkgs = {
    config = {
      allowUnfree = true;
    };
  };

  macos-only = {
    services.nix-daemon.enable = true;
  };
}
