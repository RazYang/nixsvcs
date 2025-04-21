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
      ${pkgs.coreutils}/bin/sleep 3;
      echo ${sname}
    done
  '';
in
mkS6Longrun {
  inherit sname run deps;
}
