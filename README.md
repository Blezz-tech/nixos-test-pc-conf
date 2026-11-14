# nixos-conf

NixOS + home-manager для одной машины (`nixos-jenya`).

- [TODO](./docs/TODO.md)
- [План рефакторинга и разбор репозитория](./docs/REFACTORING.md)
- [Заметки и ссылки](./docs/notes/reference.md)
- [Пакеты «на попробовать»](./docs/notes/packages-wishlist.md)
- [Заготовки модулей](./docs/snippets/)

## Структура

```
flake.nix        # тонкий: инпуты + nixosConfigurations/formatter/devShells/checks
hosts.nix        # описание машин (username, stateVersion, путь к репозиторию)
lib/             # allModules, mkHost, genNixos
nixos/           # системные модули: modules/, programs/, services/, overlays/, pkgs/
home/            # home-manager: programs/, shell/, xdg/
scripts/         # вспомогательные shell-скрипты
docs/            # TODO, заметки, заготовки
```

Модули внутри `nixos/modules`, `nixos/programs`, `nixos/services`, `home/programs`,
`home/programs/packs`, `home/shell` подхватываются автоматически (`libx.allModules`) —
новый файл не нужно никуда вписывать.

## Сборка

```bash
nixos-rebuild switch --flake .#nixos-jenya   # или: nh os switch
nixos-rebuild build  --flake .#nixos-jenya   # собрать без активации
```

## Разработка

```bash
nix develop      # devShell: nixd/nil, treefmt, statix, deadnix, nh
nix fmt          # nixfmt + deadnix + statix + shfmt
nix flake check  # проверяет, что конфигурация вычисляется
```

## Секреты

`tg-ws-proxy` читает секрет из `~/tg-ws-proxy-secret` (вне репозитория).
Планируется перевод на `sops-nix` — см. `docs/REFACTORING.md`, этап 6.

## Благодарность

Спасибо людям за свои конфиги — они сильно помогают и облегчают жизнь.

- [ReStranger](https://github.com/ReStranger/nixos-config) — идеи структуры (hosts/lib/автоимпорт), CI
- [spector700](https://github.com/spector700/Akari) — настройка neovim (nixvim)
- [FUFSoB](https://github.com/FUFSoB/proxy-suite-flake) — модуль `proxy-suite` (zapret, tg-ws-proxy)
