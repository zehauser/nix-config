{
  boot.initrd.supportedFilesystems = [ "btrfs" ];

  swapDevices = [ { label = "swap"; } ];

  fileSystems."/boot" = {
    device = "/dev/disk/by-label/nixos-boot";
    fsType = "ext4";
  };

  fileSystems."/nix" = {
    device = "/dev/disk/by-label/primary";
    fsType = "btrfs";
    options = [ "subvol=nix" ];
  };

  fileSystems."/persistent" = {
    device = "/dev/disk/by-label/primary";
    fsType = "btrfs";
    neededForBoot = true;
    options = [ "subvol=persistent" ];
  };

  fileSystems."/" = {
    device = "/dev/disk/by-label/primary";
    fsType = "btrfs";
    options = [ "subvol=root" ];
  };

}
