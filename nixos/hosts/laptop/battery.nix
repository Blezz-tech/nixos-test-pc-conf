# Батарея и мобильное железо: только у ноутбука.
{ lib, ... }:
{
  services.thermald.enable = true;
  services.tlp.enable = true;

  # plasma6 включает power-profiles-daemon вместе с powerManagement (его
  # ставит nixos/workstation/), а ppd несовместим с tlp: его модуль падает
  # assertion'ом и требует выбрать что-то одно. Выбор — tlp: он же управляет
  # порогами заряда и частотой. Профили питания в KDE отдаёт его pd.
  # services.upower.enable не трогаем: plasma6 включает его сам, вместе
  # с powerManagement.
  services.power-profiles-daemon.enable = lib.mkForce false;
  services.tlp.pd.enable = true;

  # performance из nixos/workstation/ на батарее не нужен: губернатором
  # занимается tlp.
  powerManagement.cpuFreqGovernor = lib.mkForce "schedutil";
}
