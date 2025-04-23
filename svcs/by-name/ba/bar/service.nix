{
  pkgs,
  sname ? builtins.baseNameOf ./.,
  foo,
  foo2,
  deps ? [
    foo
    foo2
  ],
  mkS6Longrun,
  ...
}:
let
  run = pkgs.writeShellScript "${sname}-run" ''
    while true;do
      echo ${sname}
      ${pkgs.s6-portable-utils}/bin/s6-sleep 3;
    done
  '';
in
mkS6Longrun {
  inherit sname run deps;
}
