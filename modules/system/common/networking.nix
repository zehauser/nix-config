{
  config,
  helpers,
  lib,
  ...
}:
helpers.mkCrossPlatformModule {

  networking.hostName = helpers.machineName;

  macos-only = {
    networking.computerName = helpers.machineName;
  };

  nixos-only = {
    networking.firewall.enable = true;

    networking.useDHCP = true;

    networking.wireless.enable = true;
    sops.secrets."wpa_supplicant.conf" = {
      path = "/etc/wpa_supplicant.conf";
    };
  };
}
