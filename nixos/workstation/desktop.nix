# Графическая часть рабочей станции: KDE, вход в систему, портал, питание.
# Подключается из машин, которым нужен рабочий стол (nixos/hosts/<имя>/),
# поэтому сервер её не получает.
#
# Всё, что специфично для железа (батарея, второй монитор, губернатор частоты),
# живёт в nixos/hosts/<имя>/, а не здесь.
{
  username,
  ...
}:
{
  # xdg_open should work in steam_run this way… well it’s not
  # https://github.com/NixOS/nixpkgs/issues/160923
  xdg.portal = {
    enable = true;
    xdgOpenUsePortal = true;
  };

  services.desktopManager.plasma6.enable = true;

  services.displayManager = {
    plasma-login-manager.enable = true;
    autoLogin = {
      enable = true;
      user = username;
    };
  };

  # Губернатор performance: на десктопе осознанный выбор, на ноутбуке
  # перекрывается своим значением в nixos/hosts/laptop/.
  powerManagement.enable = true;
  powerManagement.cpuFreqGovernor = "performance";
}
