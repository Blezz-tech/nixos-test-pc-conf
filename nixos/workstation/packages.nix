# Пакеты, которые нужны только там, где есть графика и пользователь за столом.
# Базовые утилиты (curl, git, ddrescue) остаются в nixos/packages.nix — они
# нужны и серверу.
{ pkgs, ... }:
{
  environment.systemPackages = [
    pkgs.testdisk-qt # восстановление таблиц разделов, живой диск — в GUI
    pkgs.xdg-utils # xdg-open
    pkgs.libdecor # оформление окон для Wayland-приложений вне Plasma (SDL/GLFW)
    pkgs.steam-run # запуск чужих бинарей и AppImage-подобных сборок
    pkgs.vlc # медиаплеер
  ];
}
