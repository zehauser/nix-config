###########
# alcedo (NixOS)
#
# Raspberry Pi 4 sitting on my shelf at home — the primary playground for my NixOS adventures.
###########
{ config, inputs, ... }:
{
  services.tailscale.port = 41777;

  imports = [
    inputs.argon-fan-manager.nixosModules.aarch64-linux.default
    inputs.nixos-hardware.nixosModules.raspberry-pi-4
  ];
  hardware.raspberry-pi."4".i2c1.enable = true;

  modules.atuin-server.enable = true;
  modules.calibre.enable = true;
  modules.mosquitto.enable = true;

  modules.vscode-server.enable = true;
  home-manager.sharedModules = [ inputs.vscode-server.homeModules.default ];
  home-manager.users.zhauser.services.vscode-server.enable = true;

  modules.realtime-clock.enable = true;
  hardware.raspberry-pi."4".apply-overlays-dtmerge.enable = true;

  environment.etc.nixos.source = "/home/zhauser/nix-config";

  nix.settings.keep-outputs = true;
  nix.extraOptions = ''
    secret-key-files = ${config.sops.secrets."nix-cache-key-private".path}
  '';
  sops.secrets."nix-cache-key-private" = { };

  home-manager.users.zhauser.modules.impermanence.directories = [
    "nix-config"
    "persistent-scratch"
    ".vscode-server"
  ];
}
