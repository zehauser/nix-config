{ config, lib, ... }:
{
  options.modules.impermanence.directories =
    with lib.types;
    lib.mkOption {
      default = [ ];
      type = listOf str;
    };

  config.home.persistence."/persistent/bind-mounted/${config.home.homeDirectory}" = {
    directories = [ ".persistent" ] ++ config.modules.impermanence.directories;
    allowOther = true;
  };
}
