{ pkgs, ... }:
{
  mkS6Longrun =
    {
      sname,
      run,
      deps ? [ ],
      ...
    }:
    pkgs.runCommand "service-${sname}" { } ''
      mkdir -p $out/dependencies.d
      pushd $out/dependencies.d
        for each in ${builtins.toString deps};do
          ln -s $each/sname ./$(cat $each/sname)
        done
      popd
      ln -s ${run} $out/run
      echo longrun > $out/type
      echo ${sname} > $out/sname
    '';
  mkS6Oneshot = { }: { };
}
