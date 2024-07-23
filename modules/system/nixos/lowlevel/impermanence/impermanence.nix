{
  config,
  inputs,
  lib,
  ...
}:
{
  imports = [ inputs.impermanence.nixosModules.impermanence ];

  options.modules.impermanence.directories =
    with lib.types;
    lib.mkOption {
      default = [ ];
      type = listOf str;
    };

  config = {
    fileSystems."/persistent".neededForBoot = true;

    environment.persistence."/persistent/bind-mounted" = {
      hideMounts = true;
      directories = [
        "/var/log"
        "/var/lib/nixos"
        "/var/lib/systemd"
      ] ++ config.modules.impermanence.directories;
    };

    # /etc/machine-id needs to be present earlier than Impermanence will do the bind-mount,
    # otherwise it's recreated by the system
    environment.etc.machine-id.source = "/persistent/machine-id";
  };
}
