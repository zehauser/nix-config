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
    nix.linux-builder.enable = true;
    nix.linux-builder.maxJobs = 8;
    nix.settings.keep-outputs = true;
  };
}
