{ pkgs, ... }:
{
  environment.systemPackages = with pkgs; [ fish ];

  fonts.packages = with pkgs; [
    roboto
    nerd-fonts.hack
  ];

  homebrew.brews = [ "switchaudio-osx" ];
}
