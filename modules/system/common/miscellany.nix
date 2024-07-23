{
  helpers,
  inputs,
  lib,
  ...
}:
{
  time.timeZone = "America/Los_Angeles";

  system.configurationRevision = inputs.self.rev or inputs.self.dirtyRev;

  system.stateVersion = lib.mkMerge [
    (helpers.mkIfMacos 4)
    (helpers.mkIfNixos "23.11")
  ];
}
