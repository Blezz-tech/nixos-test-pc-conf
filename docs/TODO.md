# TODO

Правило: здесь только задачи, которые можно **закрыть галочкой**.
Сниппеты → [`snippets/`](./snippets/), заметки и ссылки → [`notes/`](./notes/),
план большого рефакторинга → [`REFACTORING.md`](./REFACTORING.md).

## Сейчас

- [ ] Отправить словари `dabkrs`/`dabruks` в `~/dicts/` через home-manager
- [ ] Сделать пакет `stepik-oauth2-videodownloader` — <https://github.com/StepicOrg/stepik-oauth2-videodownloader>
- [ ] Отключение звука по HDMI (чтобы монитор не звучал)
- [ ] Проверить настройки TTY — [`nixos/modules/tty.nix`](../nixos/modules/tty.nix)
- [ ] Удалить модуль zapret, когда он появится в nixpkgs
      (сейчас используется `proxy-suite`, локальная заготовка — `snippets/services/zapret.nix`)
- [ ] Прогнать один раз `nix fmt` и убрать `continue-on-error` из CI
      (`.github/workflows/checks.yml`)

## Сломанное ПО / известные проблемы

| Что | Проблема | Ссылка |
| --- | --- | --- |
| `clr` (OpenCL) | ломается — выключены blender и `hardware.amdgpu.opencl` | <https://github.com/NixOS/nixpkgs/issues/417992> |

## Рефакторинг

Этапы и обоснование — [`REFACTORING.md`](./REFACTORING.md).
Сделано: этапы 0–3 (гигиена, автоформат/CI, параметризация, автоимпорт модулей).

Осталось:

- [ ] Этап 4: локальные пакеты → `pkgs/<name>/package.nix` + `lib.packagesFromDirectoryRecursive`
- [ ] Этап 4: `DABRKS`/`DABRUKS` — один пакет, без `builtins.currentTime`
- [ ] Этап 4: `MURMUR`/`davinci`/`tg-ws-proxy` — вынести в отдельный флейк пакетов
- [ ] Этап 5: консолидировать `chromium`/`firefox`/`kdeconnect` между NixOS и HM
- [ ] Этап 6: секреты в sops-nix (`tg-ws-proxy` secret)
- [ ] Этап 7: `README`, devShell, скриншоты

## Хочу попробовать

Пакеты — [`notes/packages-wishlist.md`](./notes/packages-wishlist.md).

## Мелочи из старых заметок

- [ ] Перенос «мусора» из `~` в `~/.uwucache` (`~/.cargo` уже перенесён через `CARGO_HOME`;
      остальные — по <https://stackoverflow.com/questions/38050995>)
- [ ] `keyd` — см. `notes/reference.md`
- [ ] Загрузочный экран: plymouth уже включён (`nixos/hardware-configuration.nix`),
      проверить тему `lone`
- [ ] Обои: пакет `snippets/wallpapers-package.nix` + симлинк в `~/media/images/pkgs/`
- [ ] `yakuake` — решить, нужен ли
- [ ] `xdg.mime` / `xdg.portal` — см. `notes/reference.md` и `snippets/xdg-portal.nix`
- [ ] Тянка в fastfetch — `snippets/ascii-art.md`
