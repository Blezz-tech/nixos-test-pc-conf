# Заготовка из docs/notes/reference.md: shell с оптимизацией под процессор.
#
# ВНИМАНИЕ: требует системной фичи gccarch-alderlake у билдера.
let
  pkgs = import <nixpkgs> {
    localSystem = {
      gcc.arch = "alderlake";
      gcc.tune = "alderlake";
      system = "x86_64-linux";
    };
  };
in
pkgs.mkShell {
  buildInputs = [ pkgs.nodejs ];
}
