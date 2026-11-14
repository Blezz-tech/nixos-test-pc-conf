# Заготовка из docs/TODO.md: проверить xdg.portal с порталом KDE.
#
# Порядок проверки:
#   1. закомментировать модуль xdg (home/xdg) и проверить, что всё работает;
#   2. попробовать вернуть и добавить extraPortals.
{ pkgs, lib, ... }:
{
  xdg.portal = {
    enable = true;
    extraPortals = [ pkgs.kdePackages.xdg-desktop-portal-kde ];
    configPackages = lib.mkDefault [ pkgs.kdePackages.xdg-desktop-portal-kde ];
  };
}
