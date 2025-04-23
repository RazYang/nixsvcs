{
  nixpkgs,
  nixpkgsConfig ? { },
  overlays ? [ ],
  ...
}@args:
let
  pkgs = (import nixpkgs nixpkgsConfig) // {
    native = import nixpkgs (builtins.removeAttrs nixpkgsConfig [ "crossSystem" ]);
  };
  lib = nixpkgs.lib // (import ../lib nixpkgs.lib);
  callSelf = newArgs: import ./. (args // { nixpkgsConfig = (args.nixpkgsConfig // newArgs); });

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
        inherit crossSystem;
      }
    ) lib.systems.examples;
  };

  svcClosure = self: supper: {
    svcClosure = lib.pipe (callSelf { }) [
      (lib.mapAttrs (
        name: value:
        if lib.isDerivation value then
          self.mkS6ServiceClosure {
            inherit name;
            rootPaths = [ value ];
          }
        else
          value
      ))
    ];
  };

  svcImage = self: supper: {
    svcImage = lib.pipe (callSelf { }).svcClosure [
      (lib.mapAttrs (
        name: value:
        pkgs.dockerTools.buildImage {
          name = "${name}";
          tag = "latest";
          copyToRoot = pkgs.buildEnv {
            name = "${name}-root";
            paths = [ value ];
            pathsToLink = [ "/bin" ];
          };
        }
      ))
    ];
  };

  toFix = lib.foldl' (lib.flip lib.extends) (self: { }) (
    [
      svcImage
      svcClosure
      svcsCross
      autoCalledServices
      allServices
    ]
    ++ overlays
  );
in
lib.fix toFix
