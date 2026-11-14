{ pkgs, ... }:
{
  home.packages = with pkgs; [
    unrar-free
    zip
    xz
    unzip
    _7zz
    zstd
  ];
}
