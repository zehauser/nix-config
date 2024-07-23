{ inputs, pkgs, ... }:
{
  programs.vscode = {
    enable = true;
    package = pkgs.vscode;
    mutableExtensionsDir = false;
    extensions = with inputs.nix-vscode-extensions.extensions.${pkgs.system}.vscode-marketplace; [ jnoortheen.nix-ide ];

    userSettings = {
      "window.autoDetectColorScheme" = true;
      "workbench.colorTheme" = "Default Light Modern";
      "editor.fontFamily" = "Hack Nerd Font, Menlo, Monaco, 'Courier New', monospace";
      "editor.formatOnSave" = true;
      "nix.formatterPath" = [
        "${pkgs.nixfmt-rfc-style}/bin/nixfmt"
        "--width"
        "120"
      ];
      "window.openFoldersInNewWindow" = "on";
    };

    keybindings = [
      {
        key = "cmd+shift+up";
        command = "editor.action.moveLinesUpAction";
        when = "editorTextFocus && !editorReadonly";
      }
      {
        key = "cmd+shift+down";
        command = "editor.action.moveLinesDownAction";
        when = "editorTextFocus && !editorReadonly";
      }
    ];
  };
}
