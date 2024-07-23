{
  config,
  helpers,
  lib,
  pkgs,
  ...
}:
helpers.mkCrossPlatformModule {
  home-manager.users.zhauser.imports = lib.concatMap (path: helpers.listModulesRecursively (helpers.flakeRoot + path)) (
    [ /modules/home/common ]
    ++ (
      if helpers.isMacos then
        [ /modules/home/macos ]
      else if helpers.isNixos then
        [ /modules/home/nixos ]
      else
        [ ]
    )
  );

  users = {
    users.zhauser = {
      shell = pkgs.fish;
      home = lib.mkMerge [
        (helpers.mkIfMacos "/Users/zhauser")
        (helpers.mkIfNixos "/home/zhauser")
      ];
      openssh.authorizedKeys.keys = [ "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIF7ousJETuKpuldY9ZT19mScCxsiVUW46WI+bZYGbDF+" ];
    };
  };

  # Because we're setting users.users.zhauser.shell to fish, we also need to enable fish.
  programs.fish.enable = true;

  # On Mac, programs.fish.enable doesn't seem to set environment.shells, and more importantly users.users.zhauser.shell
  # isn't actually enforced (due, AFAICT, to a wider conversation in nix-darwin about to what extent it's safe to
  # manage a preexisting admin user — so this may change).
  environment.shells = helpers.mkIfMacos [ "${pkgs.fish}/bin/fish" ];
  macos-only.system.activationScripts.postUserActivation.text = helpers.mkIfMacos ''
    sudo dscl . -create /Users/zhauser UserShell ${pkgs.fish}/bin/fish
  '';

  nixos-only = {
    users = {
      mutableUsers = false;

      users.zhauser = {
        isNormalUser = true;
        extraGroups = [ "wheel" ];
        hashedPasswordFile = config.sops.secrets."hashed_user_passwords/zhauser".path;
      };

      users.root.hashedPassword = "!"; # disable root password login
    };

    sops.secrets."hashed_user_passwords/zhauser".neededForUsers = true;

    security.sudo.extraRules = [
      {
        groups = [ "wheel" ];
        commands = [
          {
            command = "ALL";
            options = [ "NOPASSWD" ];
          }
        ];
      }
    ];
  };
}
