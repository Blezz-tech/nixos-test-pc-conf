# Ноутбук. Машинная часть.
#
# hardware-configuration.nix пока нет: при установке —
#   nixos-generate-config --root /mnt
# и скопировать /mnt/etc/nixos/hardware-configuration.nix сюда. Файл
# подключится сам, менять этот файл не нужно (см. libx.optionalModules).
{ lib, libx, ... }:
{
  imports =
    libx.optionalModules ./hardware-configuration.nix ++ [ ../../workstation ] ++ libx.allModules ./.;

  # Пока hardware-configuration.nix нет, NixOS не инстанцируется: падает
  # assertion «fileSystems не задаёт корневую ФС». Заглушка нужна только для
  # этого — как только файл появится, условие станет ложным и она исчезнет сама.
  # Устанавливаться с ней нельзя: путь /dev/disk/by-label/nixos условный.
  fileSystems."/" = lib.mkIf (!builtins.pathExists ./hardware-configuration.nix) {
    device = "/dev/disk/by-label/nixos";
    fsType = "ext4";
  };
}
