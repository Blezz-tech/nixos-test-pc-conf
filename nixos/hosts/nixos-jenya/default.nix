# Десктоп. Машинная часть: свой hardware-configuration.nix, своя графика,
# свои программы.
#
# hardware-configuration.nix генерируется `nixos-generate-config` и помечен
# "Do not modify this file" — правки в нём теряются при следующей генерации.
{ libx, ... }:
{
  imports =
    libx.optionalModules ./hardware-configuration.nix ++ [ ../../workstation ] ++ libx.allModules ./.;
}
