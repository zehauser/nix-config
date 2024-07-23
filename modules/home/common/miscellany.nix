{ helpers, ... }:
{
  programs.man.generateCaches = false;
  programs.command-not-found.enable = false;

  systemd.user.startServices = helpers.mkIfNixos "sd-switch";

  home.stateVersion = "24.05";
}
