###########
# mergus (NixOS)
#
# Raspberry Pi Zero 2W hiding behind a couch far away from home. It's nice to have redundant DNS, and to send traffic
# through another country from time to time.
###########
{
  nix.settings.trusted-public-keys = [ "alcedo.myth-bee.ts.net-1:z+8YzpvY/zp1lsNItBMp7Xbv9zufbYx1ls+d+X22frM=" ];

  home-manager.users.zhauser.modules.impermanence.directories = [ "persistent-scratch" ];

  nix.gc = {
    automatic = true;
    dates = "*-*-* 03:30:00 America/Los_Angeles";
    options = "--delete-old";
  };
  systemd.timers.nix-gc = {
    wants = [ "time-sync.target" ];
    after = [ "time-sync.target" ];
  };
}
