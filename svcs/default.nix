{
  nixpkgs,
  nixpkgsConfig ? { },
  overlays ? [ ],
  ...
}@args:
let
  pkgs = import nixpkgs nixpkgsConfig;
  lib = nixpkgs.lib // (import ../lib nixpkgs.lib);

  autoCalledServices = import ./by-name-overlay.nix lib ./by-name;
  allServices =
    self: supper:
    let
      res = import ./all-services.nix { inherit lib pkgs; } res self supper;
    in
    res;

  svcsCross =
    self: supper: {
       svcsCross = lib.mapAttrs (_: crossSystem: import ./. (args // { nixpkgsConfig = nixpkgsConfig // {inherit crossSystem;}; })) lib.systems.examples;
    };

  toFix = lib.foldl' (lib.flip lib.extends) (self: { }) (
    [
      svcsCross
      autoCalledServices
      allServices
    ]
    ++ overlays
  );
in
lib.fix toFix
