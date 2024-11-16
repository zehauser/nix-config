{ pkgs, ... }:
{
  environment.systemPackages = with pkgs; [ fish ];

  fonts.packages = with pkgs; [
    roboto
    (nerdfonts.override { fonts = [ "Hack" ]; })
  ];

  homebrew.brews = [ "switchaudio-osx" ];
}
