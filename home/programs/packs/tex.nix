{ pkgs, ... }:
let
  tex = pkgs.texliveSmall.withPackages (
    ps: with ps; [
      fontspec
      polyglossia
      amsmath
      hyphen-russian
      standalone
      luatex85
      pgfplots
      cancel
      lualatex-math
      enumitem
    ]
  );
in
{
  home.packages = with pkgs; [
    tex
    ghostscript
    pdf2svg
    poppler-utils
    pdftk
    mupdf
  ];
}
