{
  nixpkgs,
  nixpkgsConfig ? { },
  overlays ? [ ],
  ...
}@args:
let
  pkgs = import nixpkgs nixpkgsConfig;
  lib = nixpkgs.lib // (import ../lib nixpkgs.lib);
  callSelf = newArgs: import ./. args // newArgs;

  autoCalledServices = import ./by-name-overlay.nix lib ./by-name;
  allServices =
    self: supper:
    let
      res = import ./all-services.nix { inherit lib pkgs; } res self supper;
    in
    res;

  svcsCross = self: supper: {
    svcsCross = lib.mapAttrs (
      _: crossSystem:
      callSelf {
        nixpkgsConfig = nixpkgsConfig // {
          inherit crossSystem;
        };
      }
    ) lib.systems.examples;
  };

  svcClosure = self: supper: {
    svcClosure = lib.pipe (callSelf { }) [
      (lib.mapAttrs (
        name: value:
        if lib.isDerivation value then self.mkS6ServiceClosure { rootPaths = [ value ]; } else value
      ))
    ];
  };

  toFix = lib.foldl' (lib.flip lib.extends) (self: { }) (
    [
      svcClosure
      svcsCross
      autoCalledServices
      allServices
    ]
    ++ overlays
  );
in
lib.fix toFix
