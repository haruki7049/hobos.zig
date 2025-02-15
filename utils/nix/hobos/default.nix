{ stdenv
, lib
, zig
}:

stdenv.mkDerivation {
  pname = "hobos";
  version = "dev";

  src = lib.cleanSource ../../..;

  nativeBuildInputs = [
    zig.hook
  ];
}
