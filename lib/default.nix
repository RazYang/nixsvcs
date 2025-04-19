lib: {
  test = _: "test";
  infuse = (import ./infuse.nix { inherit lib; }).v1.infuse;
}
