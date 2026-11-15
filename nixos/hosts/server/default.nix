# Сервер. Машинная часть.
#
# Пока машины нет, конфигурация выключена: enabled = false в hosts.nix.
# Порядок установки — docs/notes/hosts.md.
{ lib, ... }:
{
  imports = lib.optionals (builtins.pathExists ./hardware-configuration.nix) [
    ./hardware-configuration.nix
  ];

  # Загрузчик сервера — GRUB на весь диск; конкретные устройства появляются
  # вместе с hardware-configuration.nix:
  #   boot.loader.grub.devices = [ "/dev/sda" ];
  #
  # Консоль по serial-порту — на случай, если монитора рядом нет:
  # boot.kernelParams = [ "ttyS0,115200n8" "console=ttyS0" ];
}
