# Сервер. Машинная часть: без графики, без home-manager (см. hosts.nix).
#
# hardware-configuration.nix пока нет: при установке —
#   nixos-generate-config --root /mnt
# и скопировать сюда. Файл подключится сам.
{ lib, libx, ... }:
{
  imports = libx.optionalModules ./hardware-configuration.nix ++ libx.allModules ./.;

  # Пока hardware-configuration.nix нет, NixOS не инстанцируется: падает
  # assertion «fileSystems не задаёт корневую ФС». Заглушка нужна только для
  # этого — как только файл появится, условие станет ложным и она исчезнет сама.
  # Устанавливаться с ней нельзя: путь /dev/disk/by-label/nixos условный.
  fileSystems."/" = lib.mkIf (!builtins.pathExists ./hardware-configuration.nix) {
    device = "/dev/disk/by-label/nixos";
    fsType = "ext4";
  };
}
