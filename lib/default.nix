lib: {
  infuse = (import ./infuse.nix { inherit lib; }).v1.infuse;
  yants = import ./yants.nix { inherit lib; };
}
