# Реестр хостов. Имя атрибута — это одновременно имя конфигурации во флейке
# (nixosConfigurations.<имя>), networking.hostName и имя каталога в
# nixos/hosts/ (машинная часть) и home/hosts/ (домашняя, если нужна).
#
# Поля записи:
#   system      — платформа сборки;
#   username    — единственный пользователь машины (уходит в specialArgs);
#   homeManager — есть ли на машине home-manager. У сервера его нет совсем:
#                 модуль home-manager к такой конфигурации не подключается;
#   modules     — дополнительные модули NixOS только для этой машины
#                 (обычно не нужно: всё складывается в nixos/hosts/<имя>/).
{
  nixos-jenya = {
    system = "x86_64-linux";
    username = "jenya";
    homeManager = true;
  };

  # Ноутбук: та же графическая часть, что у десктопа, но своё железо
  # (nixos/hosts/laptop/) и свои домашние программы (home/hosts/laptop/).
  laptop = {
    system = "x86_64-linux";
    username = "jenya";
    homeManager = true;
  };

  # Сервер: без графики и без home-manager.
  server = {
    system = "x86_64-linux";
    username = "jenya";
    homeManager = false;
  };
}
