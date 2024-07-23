/**
  `mkCrossPlatformModule` is a preprocessor for Nix modules that allows certain imports or config options to be
  conditionally defined based on platform (MacOS or NixOS).

  Normally (i.e., without `mkCrossPlatformModule`), config options can be conditionally defined via constructs such as
  `lib.mkIf`. However, this doesn't work if the option is only actually *declared* on one platform, e.g. because a base
  NixOS option isn't present in nix-darwin or because a dependency (e.g. a home-manager module from a flake) is only
  imported on one of the platforms. Also, `lib.mkIf` is only for config, not for imports or option declarations.

  `mkCrossPlatformModule` allows imports and config options to be defined in platform-specific attrsets. Once preprocessed,
  the attributes of the target platform are hoisted to the top-level, while the attributes of the other platforms are
  stripped out.

  Is this actually better than just passing around the `is{Platform}` variables, and conditionally using `++` and `//`
  in each module? The jury is out. The point of `mkCrossPlatformModule` is to make the modules easier to read, but
  perhaps that's outweighed by "overly magical".

  # Example

  ```nix
  let
    mkCrossPlatformModule = (import ./mkCrossPlatformModule.nix) { inherit lib; platform = "nixos"; };
  in
  mkCrossPlatformModule {
    imports = [ common-module ];
    system.option = [ 1 2 3 ];
    macos-only.imports = [ macos-module ];
    nixos-only.imports = [ nixos-module ];
    nixos-only.system.option = [ 4 5 6 ];
  }
  =>
  {
    imports = [ common-module nixos-module ];
    system.option = lib.mkMerge [
      [ 1 2 3 ]
      [ 4 5 6 ]
    ];
  }
  ```
*/
{ lib, platform }:
module:
let
  inherit (builtins) length;
  inherit (lib.attrsets) mapAttrsToList;

  normalize =
    module:
    let
      topLevelConfigAttrs = mapAttrsToList (attr: _: attr) (
        removeAttrs module [
          "imports"
          "options"
          "config"
        ]
      );
    in
    if (module ? options || module ? config) && length topLevelConfigAttrs != 0 then
      abort "invalid module: module shorthand form is not permitted if `options` or `config` is provided"
    else
      {
        imports = module.imports or [ ];
        options = module.options or { };
        config =
          module.config or (removeAttrs module [
            "imports"
            "options"
          ]);
      };

  commonModule = normalize (
    removeAttrs module [
      "macos-only"
      "nixos-only"
    ]
  );

  platformModule = normalize (module."${platform}-only" or { });
in
if platform != "macos" && platform != "nixos" then
  abort "Unrecognized `platform`: ${platform}"
else if builtins.length (mapAttrsToList (attr: _: attr) platformModule.options) != 0 then
  abort "platform-specific options are not yet supported"
else if commonModule ? disabledModules || platformModule ? disabledModules then
  abort "disabledModules is not yet supported"
else
  {
    imports = commonModule.imports ++ platformModule.imports;
    options = commonModule.options;
    config = lib.mkMerge [
      commonModule.config
      platformModule.config
    ];
  }
