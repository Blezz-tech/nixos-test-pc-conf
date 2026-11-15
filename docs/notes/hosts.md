# Хосты: как всё устроено и как завести новый

## Три уровня

| Уровень | Где лежит | Что внутри |
|---|---|---|
| реестр | `hosts.nix` | по атрибуту на машину: `system`, `username`, `role`, `enabled` |
| роль | `nixos/profiles/<role>.nix` | что общего у машин этого типа: `workstation` (графика, вход, питание) или `server` (ssh, zram) |
| машина | `nixos/hosts/<имя>/` | только машинное: `hardware-configuration.nix` и отличия от роли |

`libx.mkHost` собирает конфигурацию из этих частей: `nixos/` (общее) →
`nixos/profiles/<role>.nix` → `nixos/hosts/<имя>/` (если каталог существует) →
home-manager.

Имя атрибута в `hosts.nix` — это сразу имя конфигурации
(`nixosConfigurations.<имя>`), `networking.hostName` и имя каталога в `nixos/hosts/`.

## Что где писать

- тянет графику, KDE, автологин — `nixos/profiles/workstation.nix`;
- одинаково у всех машин (сеть, nix, локали, пользователь) — `nixos/modules/`;
- только у этой машины (железо, батарея, второй монитор, GRUB против
  systemd-boot) — `nixos/hosts/<имя>/default.nix`;
- пакеты, которых нет в nixpkgs — `nixos/pkgs/` + `nixos/overlays/blezz-pkgs.nix`.

## Текущее состояние

```nix
nixos-jenya = { system = "x86_64-linux"; username = "jenya"; role = "workstation"; enabled = true; };
laptop      = { ... role = "workstation"; enabled = false; };
server      = { ... role = "server";      enabled = false; };
```

`enabled = false` — это не «сломано», а «машины ещё нет»: без
`hardware-configuration.nix` собирать нечего. Такие хосты не попадают в
`nixosConfigurations`, поэтому `nix flake show` покажет только включённые.

У ноутбука в `nixos/hosts/laptop/default.nix` уже набросаны отличия от десктопа:
`upower`, `thermald`, `tlp` и перекрытие губернатора частоты. У сервера — место
под GRUB и serial-консоль.

## Завести ноутбук (или сервер)

1. Поставить `enabled = true` в `hosts.nix` у нужного хоста.
2. Загрузиться с установочного образа NixOS, разметить диск, смонтировать в `/mnt`.
3. Сгенерировать железо:

   ```bash
   nixos-generate-config --root /mnt
   ```

4. Скопировать `/mnt/etc/nixos/hardware-configuration.nix` в
   `nixos/hosts/<имя>/hardware-configuration.nix` — он подхватится сам,
   `imports` проверяет `builtins.pathExists`.
5. Поставить систему:

   ```bash
   nixos-install --flake .#<имя>
   ```

6. Дальше как обычно: `nixos-rebuild switch --flake .#<имя>`. Алиас `myBuild`
   в `home/shell/aliases.nix` собирает десктоп, для других машин — руками.

## Чего пока нет

Записано в `docs/TODO.md`:

- модули не умеют отключаться по роли: `nixos/modules/` целиком попадает и на
  сервер (звук, планшет, bluetooth, печать). Пока сервер выключен, это не мешает;
- home-manager один на всех: `home/programs/packs/` с играми и браузерами
  приедет и на сервер;
- разметка диска руками — для новых машин стоит взять `disko`;
- секретов на сервере пока нет, а им нужен `sops-nix`.
