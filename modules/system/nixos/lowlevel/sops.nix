{ helpers, inputs, ... }:

{
  imports = [ inputs.sops-nix.nixosModules.sops ];

  sops.defaultSopsFile = helpers.flakeRoot + /secrets/${helpers.machineName}.yaml;
  sops.age.keyFile = "/persistent/secrets/sops-nix/${helpers.machineName}.private.key";

  # Disable auto-import of SSH keys
  sops.age.sshKeyPaths = [ ];
  sops.gnupg.sshKeyPaths = [ ];
}
