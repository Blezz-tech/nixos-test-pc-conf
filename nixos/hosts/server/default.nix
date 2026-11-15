# Сервер. Машинная часть: без графики, без home-manager (см. hosts.nix).
#
# hardware-configuration.nix пока нет: при установке —
#   nixos-generate-config --root /mnt
# и скопировать сюда. Файл подключится сам.
{ libx, ... }:
{
  imports =
    libx.optionalModules ./hardware-configuration.nix
    ++ libx.allModules ./.;
}
