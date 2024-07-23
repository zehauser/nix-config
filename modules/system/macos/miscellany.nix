{ pkgs, ... }:

{
  environment.systemPackages = with pkgs; [ fish ];

  security.pam.enableSudoTouchIdAuth = true;

  fonts.packages = with pkgs; [
    roboto
    (nerdfonts.override { fonts = [ "Hack" ]; })
  ];

  system.defaults.screencapture.location = "~/Screenshots";
  system.activationScripts.preUserActivation.text = "mkdir -p ~/Screenshots";

  system.defaults.finder.AppleShowAllExtensions = true;
  system.defaults.finder.ShowPathbar = true;
  system.defaults.finder.ShowStatusBar = true;

  system.defaults.NSGlobalDomain.NSAutomaticCapitalizationEnabled = false;
  system.defaults.NSGlobalDomain.NSAutomaticSpellingCorrectionEnabled = false;

  system.defaults.NSGlobalDomain.NSDocumentSaveNewDocumentsToCloud = false;
  system.defaults.NSGlobalDomain.NSNavPanelExpandedStateForSaveMode = true;
  system.defaults.NSGlobalDomain.NSNavPanelExpandedStateForSaveMode2 = true;
}
