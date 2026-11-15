# Ноутбук. Машинная часть.
#
# hardware-configuration.nix пока нет: при установке —
#   nixos-generate-config --root /mnt
# и скопировать /mnt/etc/nixos/hardware-configuration.nix сюда. Файл
# подключится сам, менять этот файл не нужно (см. libx.optionalModules).
{ libx, ... }:
{
  imports =
    libx.optionalModules ./hardware-configuration.nix
    ++ [ ../../workstation ]
    ++ libx.allModules ./.;
}
