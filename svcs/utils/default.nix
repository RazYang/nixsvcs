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

  # TODO:
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
    { name, rootPaths }:
    lib.pipe (fun { inherit rootPaths; }) [
      # generate service closure
      (
        pipeArg:
        (pkgs.runCommand "${name}-closure" { } ''
          mkdir $out
          pushd $out
          ${lib.pipe pipeArg [
            (lib.map (x: "ln -s ${x} ./${x.passthru.sname}"))
            lib.concatLines
          ]}
          popd
        '')
      )

      # from service closure to init script
      (
        svcs-source:
        (
          let
            svcId = builtins.toString (builtins.match "/nix/store/(.*)-${name}-closure" "${svcs-source}");
          in
          pkgs.writeShellApplication {
            name = "init";
            runtimeEnv = {
              svcdir = "/run/${svcId}";
            };
            runtimeInputs = with pkgs; [
              s6
              s6-portable-utils.bin
              (lib.infuse s6-rc { __attr.configureFlags.__append = [ "--livedir=/run/${svcId}/live" ]; })
            ];
            bashOptions = [
              "errexit"
              "pipefail"
              "monitor"
            ];
            text = ''
              s6-mkdir -p $svcdir/scandir
              s6-rc-compile $svcdir/compiled ${svcs-source}
              s6-svscan $svcdir/scandir &
              s6-rc-init -c $svcdir/compiled $svcdir/scandir
              ${lib.pipe rootPaths [
                (lib.map (x: "s6-rc -ua change ${x.passthru.sname}"))
                lib.concatLines
              ]}
              fg > /dev/null
            '';
          }
        )
      )

    ];
}
