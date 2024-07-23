/**
  `listModulesRecursively` returns a list of all *.nix files in a given directory and all its subdirectories,
  recursively to any depth.

  # Example

  ```nix
  listModulesRecursively lib ./some/path;
  =>
  [ /some/path/file1.nix /some/path/file2.nix ]
  ```
*/
lib: directory:
let
  inherit (builtins) concatMap filter readDir;
  inherit (lib) hasSuffix;
  inherit (lib.attrsets) filterAttrs mapAttrsToList;

  findRegularFilesRecursively =
    dir:
    let
      allFiles = readDir dir;
      regularFiles = mapAttrsToList (file: _: dir + "/${file}") (filterAttrs (_: type: type == "regular") allFiles);
      directories = mapAttrsToList (file: _: dir + "/${file}") (filterAttrs (_: type: type == "directory") allFiles);
    in
    regularFiles ++ concatMap findRegularFilesRecursively directories;
in
filter (file: hasSuffix "nix" file) (findRegularFilesRecursively directory)
