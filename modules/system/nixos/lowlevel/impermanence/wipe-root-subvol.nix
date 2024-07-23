{
  config,
  lib,
  pkgs,
  ...
}:
let
  inherit (builtins)
    elem
    hasAttr
    readFile
    replaceStrings
    ;
  inherit (lib.lists) all;
  btrfsPartition = config.fileSystems."/".device;
  btrfsPartitionSystemdName = replaceStrings [ "\n" ] [ ".device" ] (
    readFile (
      pkgs.runCommand "systemd-escape-btrfs-partition" { } ''
        ${pkgs.systemdMinimal}/bin/systemd-escape -p ${btrfsPartition} >$out
      ''
    )
  );
in
{
  boot.initrd.systemd.enable = true;
  boot.initrd.systemd.enableTpm2 = false;

  boot.initrd.systemd.services.wipeRootSubvol = {
    description = "Wipe btrfs root subvolume";

    wantedBy = [ "initrd.target" ];
    requires = [ btrfsPartitionSystemdName ];
    after = [ btrfsPartitionSystemdName ];
    before = [ "sysroot.mount" ];

    unitConfig.DefaultDependencies = "no";
    serviceConfig.Type = "oneshot";

    script = ''
      mkdir /btrfs_temporary
      mount ${btrfsPartition} /btrfs_temporary

      btrfs subvolume list -o /btrfs_temporary/root | cut -f9 -d' ' | while read subvol; do
        btrfs subvolume delete "/btrfs_temporary/$subvol"
      done
      btrfs subvolume delete /btrfs_temporary/root

      btrfs subvolume create /btrfs_temporary/root

      umount /btrfs_temporary
    '';
  };

  # Assertions re: interaction with our filesystems module. We don't want to wipe the wrong partition, or fail to boot!
  assertions = [
    {
      assertion =
        btrfsPartition != null
        && all (filesystem: btrfsPartition == filesystem.device && filesystem.fsType == "btrfs") (
          map (mountpoint: config.fileSystems.${mountpoint}) [
            "/"
            "/persistent"
            "/nix"
          ]
        );
    }
    {
      assertion =
        elem "subvol=root" config.fileSystems."/".options && elem "subvol=persistent" config.fileSystems."/persistent".options;
    }
    { assertion = !hasAttr "/btrfs_temporary" config.fileSystems; }
  ];
}
