{ pkgs, ... }:

{
  security.pam.enableSudoTouchIdAuth = true;

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

  system.defaults.NSGlobalDomain."com.apple.swipescrolldirection" = false;

  system.defaults.controlcenter.BatteryShowPercentage = true;
  system.defaults.controlcenter.Bluetooth = true;
  system.defaults.controlcenter.FocusModes = true;

  system.defaults.hitoolbox.AppleFnUsageType = "Do Nothing";

  system.defaults.CustomUserPreferences."com.apple.symbolichotkeys".AppleSymbolicHotKeys = {
    "64".enabled = 0; # cmd+space spotlight (needed for Alfred)
    "65".enabled = 0; # opt+cmd+space search Finder (needed for Bartender)
  };

  system.defaults.CustomUserPreferences."com.apple.Safari" = {
    NSUserKeyEquivalents = {
      "New Personal Window" = "@$p";
      "New Tailscale Window" = "@$j";
      "New Feather Window" = "@$f";
    };

    AutoOpenSafeDownloads = 0;

    HistoryAgeInDaysLimit = 365000;

    AutoFillPasswords = 0;

    ShowFavoritesBar-v2 = 1;
  };

  system.defaults.menuExtraClock.ShowSeconds = true;

}
