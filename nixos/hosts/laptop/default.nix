# Ноутбук. Машинная часть.
#
# Пока машины нет, конфигурация выключена: enabled = false в hosts.nix.
# Что сделать при установке — docs/notes/hosts.md, коротко:
#   1. загрузиться с установочного образа;
#   2. nixos-generate-config --root /mnt → положить hardware-configuration.nix
#      рядом с этим файлом (подключится сам, см. imports ниже);
#   3. поставить enabled = true в hosts.nix;
#   4. nixos-rebuild switch --flake .#laptop.
{ lib, ... }:
{
  imports = lib.optionals (builtins.pathExists ./hardware-configuration.nix) [
    ./hardware-configuration.nix
  ];

  # Отличия от десктопа: батарея и мобильное железо.
  # tlp сам выставляет губернатор частоты, поэтому performance из профиля
  # рабочей станции перекрываем — на батарее он не нужен.
  services.upower.enable = true;
  services.thermald.enable = true;
  services.tlp.enable = true;
  powerManagement.cpuFreqGovernor = lib.mkForce "schedutil";
}
