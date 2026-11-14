{ pkgs, ... }:
{
  home.packages = with pkgs; [
    # Торренты
    qbittorrent

    # Редакторы epub
    sigil

    # Графика
    drawio
    imagemagick
    oxipng # multithreaded lossless PNG/APNG compression optimizer
    ffmpeg-full
  ];
}
