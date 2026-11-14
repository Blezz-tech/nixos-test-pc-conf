{ pkgs, ... }:
{
  home.packages = with pkgs; [
    libreoffice-qt-stable
    onlyoffice-desktopeditors

    # Словари для libreoffice
    hunspell
    hunspellDicts.ru_RU
    hunspellDicts.en_US

    # Словари
    aspell
    aspellDicts.en
    aspellDicts.ru
  ];
}
