{
  pkgs,
  sname ? "bar",
  after ? null,
  ...
}:
let
  run = pkgs.writeShellScript "${sname}-run" ''
    while true;do
      ${pkgs.coreutils}/bin/sleep 3;
    done
  '';
in
pkgs.runCommand sname { } ''
  mkdir $out
  ln -s ${run} $out/run
  echo ${sname} > $out/sname
''
