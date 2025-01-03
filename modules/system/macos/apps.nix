{
  inputs,
  lib,
  pkgs,
  ...
}:
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
    "${inputs.ghostty.packages.aarch64-darwin.default}/Applications/Ghostty.app"
    "${vscode}/Applications/Visual Studio Code.app"
  ];

  homebrew.casks = [
    "1password"
    "alfred"
    "bartender"
    "cameracontroller"
    "fantastical"
    "keepingyouawake"
    "lunar"
    "obsidian"
    "sublime-text"
    "tailscale"
  ];
  homebrew.masApps = {
    "1Password for Safari" = 1569813296;
    "Things 3" = 904280696;
  };

  # Installing via environment.systemPackages ensures they're linked to via /Applications/Nix Apps, and the
  # mac-app-util script adds a "trampoline" app in /Applications/Nix Trampolines that makes them visible to Spotlight.
  environment.systemPackages = [
    inputs.ghostty.packages.aarch64-darwin.default
    iterm2
    rectangle
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

      # Temporary hack (hopefully): we need to explicitly clear SHLVL or Ghostty will end up with SHLVL=2 for some reason.
      # So we smash the nice mac-app-util trampoline with our crappy script trampoline. It works though.
      echo '#!/bin/sh' >'/Applications/Nix Trampolines/Ghostty.app/Contents/MacOS/applet'
      echo 'unset SHLVL' >>'/Applications/Nix Trampolines/Ghostty.app/Contents/MacOS/applet'
      echo 'open "/Applications/Nix Apps/Ghostty.app"' >>'/Applications/Nix Trampolines/Ghostty.app/Contents/MacOS/applet'
    '';

  system.activationScripts.postUserActivation.text =
    let
      loginItems = [
        "/Applications/Alfred 5.app"
        "/Applications/Bartender 5.app"
        "/Applications/KeepingYouAwake.app"
        "/Applications/Lunar.app"
        "/Applications/Nix Trampolines/Rectangle.app"
        "/Applications/One Thing.app"
      ];
    in
    lib.strings.concatLines (
      map (app: ''
        osascript -e 'tell application "System Events" to make login item at end with properties {path:"${app}", hidden:true}'
      '') loginItems
    );

}
