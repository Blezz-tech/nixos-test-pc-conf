# Реестр хостов. Имя атрибута — это одновременно имя конфигурации во флейке
# (nixosConfigurations.<имя>) и networking.hostName.
#
# Поля записи:
#   system   — платформа сборки;
#   username — единственный пользователь машины (уходит в specialArgs);
#   role     — какой профиль подключить: workstation (графика, звук, KDE)
#              или server (без графической части). Профили — nixos/profiles/;
#   enabled  — false: конфигурация не генерируется. Так будут жить машины,
#              которых ещё нет физически: без hardware-configuration.nix
#              собирать нечего.
#
# Машинная часть каждого хоста лежит в nixos/hosts/<имя>/ и подключается сама,
# если такой каталог существует.
{
  nixos-jenya = {
    system = "x86_64-linux";
    username = "jenya";
    role = "workstation";
    enabled = true;
  };

  # Ноутбук. Больше половины конфигурации рабочей станции подходит как есть,
  # поэтому role = workstation; различия — в nixos/hosts/laptop/default.nix.
  # Включить: сгенерировать там hardware-configuration.nix и поставить enabled = true.
  laptop = {
    system = "x86_64-linux";
    username = "jenya";
    role = "workstation";
    enabled = false;
  };

  # Сервер. Без графики и домашних приложений: role = server.
  server = {
    system = "x86_64-linux";
    username = "jenya";
    role = "server";
    enabled = false;
  };
}
