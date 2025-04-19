# copy from nixpkgs/pkgs/top-level/by-name-overlay.nix
lib: baseDirectory:
let
  inherit (builtins)
    readDir
    ;

  inherit (lib.attrsets)
    mapAttrs
    mapAttrsToList
    mergeAttrsList
    ;

  # Service files for a single shard
  # Type: String -> String -> AttrsOf Path
  namesForShard =
    shard: type:
    if type != "directory" then
      # Ignore all non-directories. Technically only README.md is allowed as a file in the base directory, so we could alternatively:
      # - Assume that README.md is the only file and change the condition to `shard == "README.md"` for a minor performance improvement.
      #   This would however cause very poor error messages if there's other files.
      # - Ensure that README.md is the only file, throwing a better error message if that's not the case.
      #   However this would make for a poor code architecture, because one type of error would have to be duplicated in the validity checks and here.
      # Additionally in either of those alternatives, we would have to duplicate the hardcoding of "README.md"
      { }
    else
      mapAttrs (name: _: baseDirectory + "/${shard}/${name}/service.nix") (
        readDir (baseDirectory + "/${shard}")
      );

  # The attribute set mapping names to the service files defining them
  # This is defined up here in order to allow reuse of the value (it's kind of expensive to compute)
  # if the overlay has to be applied multiple times
  serviceFiles = mergeAttrsList (mapAttrsToList namesForShard (readDir baseDirectory));
in
# TODO: Consider optimising this using `builtins.deepSeq serviceFiles`,
# which could free up the above thunks and reduce GC times.
# Currently this would be hard to measure until we have more services
# and ideally https://github.com/NixOS/nix/pull/8895
self: super:
{
  # This attribute is necessary to allow CI to ensure that all services defined in `pkgs/by-name`
  # don't have an overriding definition in `all-services.nix` with an empty (`{ }`) second `callService` argument.
  # It achieves that with an overlay that modifies both `callService` and this attribute to signal whether `callService` is used
  # and whether it's defined by this file here or `all-services.nix`.
  # TODO: This can be removed once `pkgs/by-name` can handle custom `callService` arguments without `all-services.nix` (or any other way of achieving the same result).
  # Because at that point the code in ./stage.nix can be changed to not allow definitions in `all-services.nix` to override ones from `pkgs/by-name` anymore and throw an error if that happens instead.
  _internalCallByNameServiceFile = file: self.callService file { };
}
// mapAttrs (name: self._internalCallByNameServiceFile) serviceFiles
