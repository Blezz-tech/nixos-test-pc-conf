{ pkgs, ... }:
{
  # KDE-приложения (остальные идеи — docs/notes/packages-wishlist.md)
  home.packages = with pkgs.kdePackages; [
    kleopatra
    kcalc
    kclock
    kjournald
    kompare
    (spectacle.override { tesseractLanguages = null; })
    filelight # интеграция с Dolphin
    kdialog # нужен arx libertatis
  ];
}
