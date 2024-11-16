###########
# Noctua (MacOS)
#
# My personal laptop and primary development machine.
###########
{ inputs, pkgs, ... }:
{
  system.defaults.dock.persistent-apps = with pkgs; [ "/System/Applications/iPhone Mirroring.app" ];

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

  home-manager.users.zhauser.programs.vscode =
    let
      python = pkgs.python311.withPackages (python-pkgs: [
        python-pkgs.ipykernel
        python-pkgs.lzstring
        python-pkgs.pyperclip
        python-pkgs.tabulate
      ]);
    in
    {
      extensions =
        with (inputs.nix-vscode-extensions.extensions.${pkgs.system}.forVSCodeVersion pkgs.vscode.version).vscode-marketplace; [
          ms-toolsai.jupyter
          ms-python.black-formatter
          ms-python.python
        ];
      userSettings = {
        "python.defaultInterpreterPath" = "${python}/bin/python";
        "notebook.formatOnSave.enabled" = true;
      };
    };
}
