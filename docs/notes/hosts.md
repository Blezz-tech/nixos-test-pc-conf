# Хосты: как устроено и как завести новую машину

## Четыре уровня

| Уровень | Где лежит | Что внутри |
|---|---|---|
| реестр | `hosts.nix` | по атрибуту на машину: `system`, `username`, `homeManager` |
| общая часть | `nixos/default.nix` | одинаково у всех: модули, программы, сервисы, оверлеи, `packages.nix`, часовой пояс |
| графика | `nixos/workstation/` | KDE, вход в систему, `xdg.portal`, питание, графические пакеты — подключают только машины с рабочим столом |
| машина | `nixos/hosts/<имя>/` | `hardware-configuration.nix` и всё, что есть только у неё |
| дом | `home/hosts/<имя>/` | домашние программы только этой машины (если на ней есть home-manager) |

`libx.mkHost` собирает: `nixos/` (общая часть) → `nixos/hosts/<имя>/` (если каталог
есть) → home-manager + `home/` (если `homeManager = true`).

Имя атрибута в `hosts.nix` — это сразу имя конфигурации
(`nixosConfigurations.<имя>`), `networking.hostName` и имя каталога в `nixos/hosts/`.

## Три машины

```nix
nixos-jenya = { system = "x86_64-linux"; username = "jenya"; homeManager = true; };
laptop      = { system = "x86_64-linux"; username = "jenya"; homeManager = true; };
server      = { system = "x86_64-linux"; username = "jenya"; homeManager = false; };
```

Чем они отличаются:

| | железо | программы | home-manager |
|---|---|---|---|
| `nixos-jenya` | `nixos/hosts/nixos-jenya/hardware-configuration.nix` | графическая часть целиком | есть |
| `laptop` | свой `hardware-configuration.nix` (появится при установке) + `battery.nix` | та же графика, плюс `tlp`/`thermald`/`upower` | есть, плюс `home/hosts/laptop/` |
| `server` | свой `hardware-configuration.nix` | без графики, только `nixos/packages.nix` + `remote.nix` | **нет** |

У сервера модуль home-manager не подключается вообще: `lib.optionals homeManager`
в `libx.mkHost` не добавляет ни `home-manager.nixosModules`, ни `users.<имя>`.
Поэтому `home/` на сервер не влияет никак.

## Завести новую машину

1. Добавить запись в `hosts.nix` (имя = будущий `hostName`):

   ```nix
   myhost = { system = "x86_64-linux"; username = "jenya"; homeManager = true; };
   ```

2. Создать `nixos/hosts/myhost/` — хотя бы `default.nix`:

   ```nix
   { libx, ... }:
   {
     imports =
       libx.optionalModules ./hardware-configuration.nix
       ++ [ ../../workstation ]   # если нужен рабочий стол
       ++ libx.allModules ./.;
   }
   ```

   `libx.allModules` подхватит остальные файлы каталога (`battery.nix`,
   `remote.nix`, `programs.nix` — как назовёте).

3. Загрузиться с установочного образа, разметить диск, смонтировать в `/mnt`,
   сгенерировать железо:

   ```bash
   nixos-generate-config --root /mnt
   ```

4. Скопировать `/mnt/etc/nixos/hardware-configuration.nix` в
   `nixos/hosts/myhost/hardware-configuration.nix`. Он подхватится сам:
   `optionalModules` проверяет `builtins.pathExists`.

5. Поставить систему и дальше обновлять как обычно:

   ```bash
   nixos-install --flake .#myhost
   nixos-rebuild switch --flake .#myhost
   ```

Если на машине не нужен home-manager — `homeManager = false`, и каталог
`home/hosts/myhost/` не создаётся.

## Заглушка корневой ФС

Пока `hardware-configuration.nix` нет, NixOS не инстанцируется: падает assertion
«`fileSystems` не задаёт корневую ФС». Поэтому в `nixos/hosts/laptop/default.nix`
и `nixos/hosts/server/default.nix` стоит самоснимающаяся заглушка:

```nix
fileSystems."/" = lib.mkIf (!builtins.pathExists ./hardware-configuration.nix) {
  device = "/dev/disk/by-label/nixos";
  fsType = "ext4";
};
```

Она нужна только для того, чтобы `nix flake check` и инстанцирование проходили;
как только появится настоящий `hardware-configuration.nix`, условие становится
ложным и заглушка исчезает. **Устанавливать систему с ней нельзя** — путь
условный.

## Что уже готово, а что нет

Готово: реестр, сборка конфигурации из трёх частей, отдельные `hardware`,
отдельные программы (`nixos/hosts/<имя>/` и `nixos/workstation/packages.nix`),
home-manager по флагу.

Не готово (в `docs/TODO.md`):

- `nixos/modules/` — общий для всех: сервер получает звук, bluetooth, печать,
  планшет. Пока это только лишние пакеты, но разделить стоит;
- `home/programs/packs/` один на всех — если у ноутбука и десктопа разойдутся
  игры/браузеры, понадобятся home-профили;
- `stateVersion` зашит `"26.05"` в `nixos/default.nix` и `home/default.nix`;
- разметку диска новых машин стоит взять из `disko`.
