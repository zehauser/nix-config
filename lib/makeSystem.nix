/**
  Given flake `inputs`, `makeSystem` returns a pair of helper functions `nixosSystem` and `macosSystem`. Each function,
  given only a machine name, is responsible for invoking `lib.{nixos,darwin}System` and passing platform-appropriate
  arguments in accordance with the repo structure:
  - `modules` list: `modules/system/common`, `modules/system/${platform}`, `modules/machines/${machineName}.nix`
  - `specialArgs.inputs`: flake `inputs`
  - `specialArgs.helpers`: small set of utilities described below

  The `helpers` utilities include:
  - `machineName` string
  - `ports` mapping
  - file helpers: `flakeRoot` path and `listModulesRecursively` function
  - cross-platform helpers: `is{Macos,Nixos}` booleans, `mkIf{Macos,Nixos}` abbreviations,
    `mkCrossPlatformModule` function
  ```
*/
inputs:
let
  platformVariables = {
    "macos" = {
      architecture = "aarch64-darwin";
      platformModulePath = ../modules/system/macos;
      lib = inputs.nixpkgs-macos.lib;
      systemFn = inputs.nix-darwin.lib.darwinSystem;
    };
    "nixos" = {
      architecture = "aarch64-linux";
      platformModulePath = ../modules/system/nixos;
      lib = inputs.nixpkgs-nixos.lib;
      systemFn = inputs.nixpkgs-nixos.lib.nixosSystem;
    };
  };

  makeHelpers =
    {
      lib,
      machineName,
      platform,
    }:
    rec {
      inherit machineName;

      ports = import ./ports.nix;

      flakeRoot = ../.;
      listModulesRecursively = import ./listModulesRecursively.nix lib;

      isMacos = platform == "macos";
      isNixos = platform == "nixos";
      mkIfMacos = lib.mkIf isMacos;
      mkIfNixos = lib.mkIf isNixos;

      mkCrossPlatformModule = import ./mkCrossPlatformModule.nix {
        inherit lib;
        inherit platform;
      };
    };

  makeSystem =
    platform: machineName:
    let
      inherit (lib) concatMap;
      inherit (lib.strings) toLower;

      inherit (platformVariables.${platform})
        architecture
        platformModulePath
        lib
        systemFn
        ;

      helpers = makeHelpers {
        inherit lib;
        inherit machineName;
        inherit platform;
      };

    in
    systemFn {
      system = architecture;
      specialArgs = {
        inherit inputs;
        inherit helpers;
      };

      modules =
        [ ../modules/machines/${toLower machineName}.nix ]
        ++ concatMap helpers.listModulesRecursively [
          ../modules/system/common
          platformModulePath
        ];
    };
in

{
  nixosSystem = makeSystem "nixos";
  macosSystem = makeSystem "macos";
}
