{
  config,
  helpers,
  inputs,
  lib,
  specialArgs,
  ...
}:
helpers.mkCrossPlatformModule {
  nixos-only.imports = [ inputs.home-manager.nixosModules.home-manager ];
  macos-only.imports = [ inputs.home-manager.darwinModules.home-manager ];

  home-manager.sharedModules = lib.mkMerge [
    [ inputs.sops-nix.homeManagerModules.sops ]
    (helpers.mkIfNixos [ inputs.impermanence.nixosModules.home-manager.impermanence ])
  ];

  home-manager.useGlobalPkgs = true;

  # I should probably enable this on Mac too, but last time I did, it made my already seemingly not-quite-right PATH
  # setup even worse. I need to get around to researching how PATH is supposed to get set on nix-darwin.
  home-manager.useUserPackages = helpers.mkIfNixos true;

  home-manager.backupFileExtension = "home-manager-backup";
  home-manager.extraSpecialArgs = specialArgs;

  nixos-only = {
    sops.secrets."home_manager_sops_keys/zhauser" = helpers.mkIfNixos {
      owner = config.users.users.zhauser.name;
      group = config.users.users.zhauser.group;
    };

    # Without this, even root can't access the home-manager+impermanence bind mounts, which is annoying.
    programs.fuse.userAllowOther = true;
  };
}
