{ inputs, pkgs, ... }:
with pkgs;
{
  system.defaults.dock.persistent-apps = [
    "/Applications/Fantastical.app"
    "/System/Cryptexes/App/System/Applications/Safari.app"
    "/System/Applications/Mail.app"
    "/System/Applications/Messages.app"
    "/Applications/Things3.app"
    "/Applications/Obsidian.app"
    "${spotify}/Applications/Spotify.app"
    "${iterm2}/Applications/iTerm2.app"
    "${vscode}/Applications/Visual Studio Code.app"
  ];

  homebrew.enable = true;
  homebrew.casks = [
    "fantastical"
    "obsidian"
    "sublime-text"
  ];
  homebrew.masApps = {
    "Things 3" = 904280696;
  };

  # Installing via environment.systemPackages ensures they're linked to via /Applications/Nix Apps, and the
  # mac-app-util script adds a "trampoline" app in /Applications/Nix Trampolines that makes them visible to Spotlight.
  environment.systemPackages = [
    iterm2
    spotify
    vscode
  ];
  system.activationScripts.postActivation.text =
    let
      mac-app-util = "${inputs.mac-app-util.packages.${pkgs.system}.default}/bin/mac-app-util";
      basename = "${coreutils}/bin/basename";
    in
    ''
      mkdir -p "/Applications/Nix Trampolines"  
      for app in "/Applications/Nix Apps/"*; do
        appname=$(${basename} "$app")
        ${mac-app-util} mktrampoline "$app" "/Applications/Nix Trampolines/$appname"
      done
    '';
}
