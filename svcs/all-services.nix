{ lib, pkgs }:
res: svcs: super: with svcs; {
  _type = "svcs";
  callService = lib.callPackageWith (svcs // { inherit pkgs lib; });

  #foo = callService ./by-name/fo/foo/service.nix {};
  #bar = callService ./by-name/ba/bar/service.nix {};
}
