###########
# Noctua (MacOS)
#
# My personal laptop and primary development machine.
###########
{
  home-manager.users.zhauser.modules.borg.enable = true;

  home-manager.users.zhauser.programs.fish = {
    shellAliases.darwin-rebuild = "darwin-rebuild --flake /Users/zhauser/code/nix-config";
    functions.nixos-rebuild = {
      argumentNames = [
        "action"
        "machine"
      ];
      body = ''
        command nixos-rebuild  --use-remote-sudo --fast \
          --target-host $machine --build-host $machine \
          --flake /Users/zhauser/code/nix-config#$machine \
          $action
      '';
    };
  };

  nix.linux-builder.enable = true;
}
