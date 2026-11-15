# Десктоп. Машинная часть: сгенерированный hardware-configuration.nix плюс то,
# чего нет у других хостов.
#
# hardware-configuration.nix появляется из `nixos-generate-config` и помечен
# "Do not modify this file" — правки в нём теряются при следующей генерации.
{ lib, ... }:
{
  imports = lib.optionals (builtins.pathExists ./hardware-configuration.nix) [
    ./hardware-configuration.nix
  ];

  # Планшет Wacom и звук по HDMI — только у этой машины.
  # (bluetooth, печать и сканер лежат в общих nixos/modules/)
}
