{
  services.openssh.enable = true;
  programs.mosh.enable = true;

  services.openssh.hostKeys = [
    {
      bits = 4096;
      path = "/persistent/secrets/ssh/ssh_host_rsa_key";
      type = "rsa";
    }
    {
      path = "/persistent/secrets/ssh/ssh_host_ed25519_key";
      type = "ed25519";
    }
  ];
}
