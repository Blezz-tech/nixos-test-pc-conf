# Доступ и минимум для машины без монитора.
{ ... }:
{
  services.openssh = {
    enable = true;
    settings.PermitRootLogin = "no";
  };

  # Вместо swap-файла: серверу не нужен лишний износ диска.
  zramSwap.enable = true;

  system.autoUpgrade.enable = false;
}
