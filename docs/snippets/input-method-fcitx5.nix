# Заготовка из docs/TODO.md / nixos/modules/i18n.nix: fcitx5 для ввода CJK.
{ pkgs, ... }:
{
  i18n.inputMethod = {
    enable = true;
    type = "fcitx5";
    fcitx5 = {
      addons = [
        pkgs.kdePackages.fcitx5-qt
        pkgs.fcitx5-rime
        pkgs.fcitx5-chinese-addons
        pkgs.rime-data
      ];
      plasma6Support = true;
      waylandFrontend = true;
    };
  };
}
