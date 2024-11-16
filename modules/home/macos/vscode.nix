{ inputs, pkgs, ... }:
{
  programs.vscode = {
    enable = true;
    package = pkgs.vscode;
    mutableExtensionsDir = false;
    extensions = with inputs.nix-vscode-extensions.extensions.${pkgs.system}.vscode-marketplace; [
      golang.go
      jnoortheen.nix-ide
    ];

    userSettings = {
      "update.mode" = "none";
      "extensions.autoUpdate" = false;
      "extensions.autoCheckUpdates" = false;
      "telemetry.telemetryLevel" = "off";
      "workbench.enableExperiments" = false;

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

      "black-formatter.args" = [
        "--line-length"
        "105"
      ];

      "go.toolsManagement.autoUpdate" = true;
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
