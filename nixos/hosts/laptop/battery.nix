# Батарея и мобильное железо: только у ноутбука.
{ lib, ... }:
{
  services.upower.enable = true;
  services.thermald.enable = true;
  services.tlp.enable = true;

  # performance из nixos/workstation/ на батарее не нужен, а tlp всё равно
  # выставляет губернатор сам.
  powerManagement.cpuFreqGovernor = lib.mkForce "schedutil";
}
