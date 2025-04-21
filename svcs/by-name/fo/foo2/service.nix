{
  pkgs,
  sname ? builtins.baseNameOf ./.,
  deps ? [ ],
  mkS6Longrun,
  ...
}:
let
  run = pkgs.writeShellScript "${sname}-run" ''
    while true;do
      ${pkgs.coreutils}/bin/sleep 3;
    done
  '';
in
mkS6Longrun {
  inherit run sname deps;
}
