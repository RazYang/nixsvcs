{
  description = "nixsvcs nix flake repository";

  inputs = {
    nixpkgs = {
      url = "github:NixOS/nixpkgs/nixos-24.11";
    };
  };

  outputs =
    inputs:
    let
      forAllSystems = with inputs.nixpkgs; lib.genAttrs lib.systems.flakeExposed;
    in
    {

      services = forAllSystems (
        system:
        import ./svcs {
          inherit (inputs) nixpkgs;
          nixpkgsConfig = {
            inherit system;
            #overlays = [];
          };
        }
      );
      lib = import ./lib inputs.nixpkgs.lib;
    };

}
