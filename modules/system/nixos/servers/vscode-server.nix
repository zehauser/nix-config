{
  config,
  inputs,
  lib,
  ...
}:
{
  imports = [ inputs.vscode-server.nixosModules.default ];

  options.modules.vscode-server.enable = lib.mkEnableOption "vscode-server";

  config = lib.mkIf config.modules.vscode-server.enable { services.vscode-server.enable = true; };
}
# Needs the user service to also be enabled via home-manager in order to work.
