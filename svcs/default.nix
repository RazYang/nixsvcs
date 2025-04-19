{
  nixpkgs,
  system,
  localSystem ? system,
  crossSystem ? localSystem,
  overlays ? [ ],
  ...
}:
let
  pkgs = import nixpkgs { inherit system; };
  lib = nixpkgs.lib // (import ../lib nixpkgs.lib);

  autoCalledServices = import ./by-name-overlay.nix lib ./by-name;
  allServices =
    self: supper:
    let
      res = import ./all-services.nix { inherit lib pkgs; } res self supper;
    in
    res;

  toFix = lib.foldl' (lib.flip lib.extends) (self: { }) (
    [
      autoCalledServices
      allServices
    ]
    ++ overlays
  );
in
lib.fix toFix
