# Рефакторинг под несколько машин

Основа — архитектура [TheMaxMur/NixOS-Configuration](https://github.com/TheMaxMur/NixOS-Configuration):
реестр хостов с параметрами, конфигурация собирается из записи реестра, машинное
лежит отдельно. Серия 01–30 (`docs/REFACTORING-STEPS.md`) дала под это базу:
`hosts.nix`, `libx`, автоимпорт, CI.

## Что взято из референса, а что нет

| Идея | Берём? | Почему |
|---|---|---|
| `hosts.nix` как реестр параметров (`username`, `platform`, флаги) | **да** | машина описывается данными, а не копипастой конфига |
| `libx.mkHost`, который разворачивает запись в `nixosSystem` | **да** | одна точка сборки на все машины |
| каталог на машину с `hardware-configuration.nix` и отличиями | **да**, `nixos/hosts/<имя>/` | железо не смешивается с общими настройками |
| `isWorkstation` как переключатель наборов | **да**, через `nixos/profiles/` | «половина конфы компа» = профиль `workstation` |
| собственные опции `module.*` с `mkEnableOption` на каждый модуль | позже | большой объём правок; сначала хватает профилей и `mkIf` |
| `disko` для декларативной разметки | позже | нужен, когда появится первая новая машина |
| `impermanence`, `stylix`, `lanzaboote`, microvm, proxmox, nix-darwin | нет | своего применения пока нет, а зависимостей много |

## Сделано

**PR #28 — инфраструктура:**

- запись хоста в `hosts.nix` получила поля `role` (профиль) и `enabled`;
- `nixos/profiles/workstation.nix` — KDE, автологин, `xdg.portal`, питание
  выехали из `nixos/default.nix`;
- `nixos/hosts/<имя>/` — машинная часть, `hardware-configuration.nix`
  подключается через `builtins.pathExists`;
- `libx.mkHost` собирает общее + профиль + машинное, `libx.enabledHosts`
  отфильтровывает выключенные хосты;
- CI инстанцирует все включённые хосты, а не один захардкоженный.

**Этот PR — заготовки:**

- `laptop` и `server` в `hosts.nix` с `enabled = false`;
- `nixos/profiles/server.nix` — sshd, zram, без графики;
- `nixos/hosts/laptop/default.nix` — `upower`, `thermald`, `tlp`, губернатор
  `schedutil` вместо `performance`;
- `nixos/hosts/server/default.nix` — место под GRUB и serial-консоль;
- `docs/notes/hosts.md` — как завести новую машину.

Поведение `nixos-jenya` не меняется: заготовки не генерируются, пока
`enabled = false`.

## Что дальше (по одному PR на шаг)

1. **Роли в модулях.** `nixos/modules/` целиком приезжает и на сервер: звук,
   планшет, bluetooth, печать. Разложить на `nixos/modules/common/` (автозагрузка
   всегда) и `nixos/modules/workstation/` (автозагрузку подключает профиль);
   альтернатива — `lib.mkIf (role != "server")` в каждом модуле. Автоимпорт это
   позволяет: профиль просто подключает нужный каталог.
2. **Роли в home-manager.** `home/profiles/workstation.nix` (packs: games,
   browsers, media, kde) и `home/profiles/server.nix` (git, zsh, eza, fzf,
   direnv, neovim). `role` уже есть в `extraSpecialArgs`.
3. **`stateVersion` из реестра.** Сейчас `"26.05"` зашит в `nixos/default.nix`
   и `home/default.nix`; у новых машин он будет свой.
4. **Второй хост на деле.** Когда появится ноутбук — `hardware-configuration.nix`,
   `enabled = true`, и сразу `nix store diff-closures` против десктопа: видно,
   что реально отличается.
5. **`disko` для новых машин.** Разметка (luks + btrfs) в
   `nixos/hosts/<имя>/disko.nix`, установка через `disko-install`. Серверу
   полезнее всего: переустановка становится воспроизводимой.
6. **Секреты.** `sops-nix` нужен и десктопу (`~/tg-ws-proxy-secret`), и серверу.
7. **Серверное.** SSH-хардening, бэкапы (`restic`), мониторинг, firewall —
   модулями в `nixos/modules/` с `mkIf role == "server"`.

## Проверка

```bash
nix flake show          # видно только включённые хосты
nix flake check         # formatting + deadnix
nixos-rebuild build --flake .#nixos-jenya
nix store diff-closures /run/current-system ./result   # пусто
```
