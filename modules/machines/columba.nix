###########
# Columba (MacOS)
#
# My work laptop.
###########
{ pkgs, ... }:
{
  homebrew.casks = [
    "chromium"
  ];

  home-manager.users.zhauser.programs.vscode = {
    extensions = with pkgs.vscode-extensions; [
      eamodio.gitlens
      stkb.rewrap
      ms-vsliveshare.vsliveshare
    ];
  };

  environment.systemPackages = with pkgs; [
    slack
  ];
  system.defaults.dock.persistent-apps = with pkgs; [
    "${slack}/Applications/Slack.app"
    "/Users/zhauser/Applications/Chromium Apps.localized/Google Meet.app"
    "/Applications/CameraController.app"
  ];

}
