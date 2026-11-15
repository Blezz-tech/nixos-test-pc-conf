# Профиль рабочей станции: графика, вход в систему, управление питанием.
# Подключается хостам с role = "workstation" (см. hosts.nix) — десктоп и ноутбук.
#
# Всё, что специфично для конкретной машины (железо, мониторы, термоконтроль),
# живёт не здесь, а в nixos/hosts/<имя>/.
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

  # Губернатор performance: на десктопе это осознанный выбор, на ноутбуке
  # может съесть батарею — переопределяется в nixos/hosts/laptop/default.nix.
  powerManagement.enable = true;
  powerManagement.cpuFreqGovernor = "performance";
}
