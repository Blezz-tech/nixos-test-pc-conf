# nixos-conf

Конфигурация NixOS на несколько машин: десктоп `nixos-jenya`, ноутбук `laptop`
и сервер `server`. Пользователь один — `jenya`.

У машин разное железо (`nixos/hosts/<имя>/hardware-configuration.nix`), разные
программы (`nixos/hosts/<имя>/` и `nixos/workstation/`) и разный набор
home-manager: у сервера его нет совсем (`homeManager = false` в `hosts.nix`).
Как завести новую машину — `docs/notes/hosts.md`.

- [Список работы](./docs/TODO.md)
- [Хосты: как завести новую машину](./docs/notes/hosts.md)
- [Как устроена серия рефакторинга](./docs/REFACTORING-STEPS.md)

## Пересборка

```bash
cd ~/nixos-pc-conf
sudo nixos-rebuild switch --flake .#nixos-jenya   # или: myBuild
sudo nixos-rebuild switch --flake .#laptop        # на ноутбуке
sudo nixos-rebuild switch --flake .#server        # на сервере
nh os switch                                      # то же через nh
```

Проверить, что изменилось в пакетах:

```bash
nixos-rebuild build --flake .#nixos-jenya
nix store diff-closures /run/current-system ./result
```

## Проверки и форматирование

```bash
nix flake check   # formatting (treefmt) + deadnix
nix fmt           # nixfmt по *.nix, shfmt по *.sh
nix develop       # treefmt, nixfmt, deadnix, statix, shfmt, nixd
```

То же гоняет GitHub Actions на каждый PR и на пуш в `master`
(`.github/workflows/check.yml`), плюс инстанцирование всей конфигурации.

## Как устроено

| Путь | Что внутри |
|---|---|
| `flake.nix` | входы и выходы; конфигурации собираются через `lib/mkHost` |
| `hosts.nix` | реестр хостов: имя атрибута = имя конфигурации и `hostName` |
| `lib/default.nix` | `mkHost` и `libx.allModules` |
| `nixos/` | системные модули, программы, сервисы, пакеты, оверлеи |
| `nixos/workstation/` | графика: KDE, вход, портал, питание, графические пакеты |
| `nixos/hosts/<имя>/` | машинное: `hardware-configuration.nix` и отличия |
| `home/hosts/<имя>/` | домашние программы конкретной машины |
| `home/` | home-manager: программы, наборы пакетов (`packs/`), shell, `xdg` |
| `docs/` | заметки, заготовки, этот рефакторинг |

Новые файлы в `nixos/{modules,programs,services}/` и `home/{programs,shell}/`
подключаются автоматически — дописывать списки импортов не нужно.
Выключенный код живёт в `docs/snippets/`, а не в дереве.

## Документация

- `docs/notes/reference.md` — сборка, hosts, xdg.portal, консоль, fcitx5, ссылки;
- `docs/notes/solved.md` — разобранные проблемы (Steam, Plymouth, GPG, SSH);
- `docs/notes/packages-wishlist.md` — пакеты, которые хочется попробовать;
- `docs/snippets/` — выключенные модули и заготовки.

## Благодарность

Спасибо людям за свои конфиги

Они сильно помогают и облегчают жизнь

- [ReStranger](https://github.com/ReStranger/nixos-config) (За настройку для запрета)
- [spector700](https://github.com/spector700/Akari) (За настройку для neovim'а)
