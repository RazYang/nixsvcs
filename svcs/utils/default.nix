{ lib, pkgs, ... }:
{
  mkS6Longrun =
    {
      sname,
      run,
      deps ? [ ],
      ...
    }:
    (pkgs.runCommand "service-${sname}" { } ''
      mkdir -p $out/dependencies.d
      pushd $out/dependencies.d
        for each in ${builtins.toString deps};do
          ln -s $each/sname ./$(cat $each/sname)
        done
      popd
      ln -s ${run} $out/run
      echo longrun > $out/type
      echo ${sname} > $out/sname
    '')
    // {
      passthru = {
        inherit sname;
        stype = "longrun";
        sdeps = deps;
      };
    };
  mkS6Oneshot = { }: { };

  # recursive get sdeps dependencies
  mkS6ServiceClosure =
    let
      fun =
        { rootPaths }:
        lib.pipe rootPaths [
          (map (drv: fun { rootPaths = drv.passthru.sdeps; }))
          lib.flatten
          (lib.concat rootPaths)
        ];
    in
    { rootPaths }:
    lib.pipe (fun { inherit rootPaths; }) [
      (lib.map (path: "ln -s ${path} ./${path.passthru.sname}"))
      lib.concatLines
      (
        commands:
        (pkgs.runCommand "service-closure" { } ''
          mkdir $out
          pushd $out
          ${commands}
          popd
        '')
      )
    ];
}
