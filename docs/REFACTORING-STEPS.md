# Как это сделано: 30 маленьких шагов

Рефакторинг разбит на **30 последовательных PR** — чтобы каждый можно было прочитать
за пару минут, а не разбираться в одном гигантском диффе.

## Как устроена серия

- PR нумерованы `01/30` … `30/30`, названия идут по порядку;
- PR'ы **последовательные**: следующий открывается после мержа предыдущего (у сессии одна
  ветка, поэтому параллельно стопкой их не выставить);
- каждый PR меняет 1–3 файла и оставляет конфигурацию рабочей;
- прогресс смотрим по номерам в заголовках PR: смержен последний — значит шаги до него сделаны.

## Шаги

Прогресс: **01–10** смержены.

| № | Шаг | Что меняется | Зачем |
|---|-----|--------------|-------|
| 01 | chore: `.gitignore` + это оглавление | `.gitignore`, `docs/REFACTORING-STEPS.md` | мусор (`result`, `.direnv`) не попадёт в репозиторий |
| 02 | chore: мёртвые модули NixOS | `modules/vr.nix`, `documentation.nix` → `docs/snippets/` | 43 из 51 строк `vr.nix` закомментированы; оба файла не импортируются |
| 03 | chore: мёртвые сервисы, часть 1 | `services/{tor,postgresql,sunshine}.nix`, `programs/obs-studio.nix` → `docs/snippets/` | модули отключены, но лежат в дереве и создают иллюзию «оно работает» |
| 04 | chore: мёртвые сервисы, часть 2 | `services/{v2raya,weblate,whoogle-search,zapret}.nix`, `overlays/envvar.nix` → `docs/snippets/` | то же; `zapret` дублирует `proxy-suite`. `syncthing.nix` остаётся: он открывает порты и подключён |
| 05 | chore: no-op опции | `permittedInsecurePackages = []`, `programs.kde-pim { enable = false; … }`, `users.packages = []` | это значения по умолчанию — строки только шумят |
| 06 | chore: неиспользуемые аргументы | `pkgs` в `programs/chromium.nix`, `services/default.nix` | deadnix-ошибки, из-за них линтер не включить. В `i18n.nix` аргумент используется, `services/postgresql.nix` уже в архиве |
| 07 | refactor: `openssh.nix` по содержимому | → `gnupg.nix` + `mtr.nix`, закомментированный `services.openssh` → `docs/snippets/openssh-server.nix` | файл называется «ssh», а внутри gpg-agent и `mtr`. При этом sshd в конфиге вообще не включён |
| 08 | refactor: разбить `modules/default.nix` (1) | `boot.nix`, `environment.nix`; убран мёртвый пример `specialisation` | 64 строки в одном файле про загрузчик, wayland-переменные и Android-эмулятор |
| 09 | refactor: разбить `modules/default.nix` (2) | `nixpkgs.nix`, `virtualisation.nix`; `default.nix` — только импорты, мёртвые примеры `libinput`/`rocmSupport` убраны, `xdg.mime` в архив | то же |
| 10 | refactor: syncthing и psd | порты syncthing → `modules/networking.nix`; `services/psd.nix`; `services/syncthing.nix` удалён | файл называется syncthing, но `services.syncthing` в нём закомментирован (он в home-manager), а живого кода — 2 строки про firewall |
| 11 | refactor: `programs/default.nix` → `system.nix` | тело файла в `system.nix`, выключенные программы → `docs/snippets/programs-disabled.nix` | `default.nix` должен быть оглавлением, а не свалкой |
| 12 | refactor: `config.nix` → `modules/plasma-systemmonitor.nix` | опция и её включение в одном файле | сейчас опция объявлена в одном файле, а включается в другом |
| 13 | refactor: `systemPackages` | убрать `home-manager` и `partitionmanager`, сгруппировать | `home-manager` подключён модулем; `partitionmanager` ставит `programs.partition-manager` |
| 14 | refactor: `home/XDG` → `home/xdg` | переименование каталога | остальные каталоги в нижнем регистре |
| 15 | refactor: `packs/default.nix` → `base.nix` | `programs.*` и keepassxc переезжают в отдельный файл | `default.nix` = только список импортов |
| 16 | refactor: data-файлы v2rayN | из `home/shell/default.nix` → `home/programs/packs/base.nix` | они про приложение, а не про shell |
| 17 | docs: wishlist пакетов | `docs/notes/packages-wishlist.md` | 176 закомментированных пакетов в коде — это не код |
| 18 | chore: `common.nix` | только реально установленные пакеты, сгруппированные | 108 из 191 строк — комментарии |
| 19 | chore: `packs`: games, media, messengers | убрать комментарии | 68 из 91 строки в `games.nix` — комментарии |
| 20 | chore: `packs`: dev, kde, archive, tex, office, browsers, custom | чистка + `nixfmt` вместо устаревшего `nixpkgs-fmt` | то же + мёртвый `myPHP` |
| 21 | docs: заметки и заготовки | `docs/notes/{reference,solved}.md`, `docs/snippets/*` | знания из комментариев в конфигах → в документацию |
| 22 | docs: переписать `TODO.md` | валидный markdown, ~10 закрываемых задач | 167 заголовков на 5 чекбоксов + незакрытый блок кода на 200 строк |
| 23 | chore: `treefmt` | `nixfmt` + `deadnix` + `statix` + `shfmt`, `.vscode` | `treefmt.toml` не подключён к флейку, а `nixpkgs-fmt` устарёл |
| 24 | feat: `nix fmt`, `nix develop`, `nix flake check` | `formatter`, `devShells`, `checks` в `flake.nix` | без этого нечем валидировать следующие шаги |
| 25 | ci: GitHub Actions | lint + `update-flake-lock` | проверки должны идти сами |
| 26 | refactor: `hosts.nix` + `lib/mkHost` | `hosts.nix`, `lib/default.nix`, `flake.nix` | `username` объявлен, но `users.jenya` — хардкод |
| 27 | refactor: автоимпорт NixOS | `nixos/{modules,programs,services}/default.nix` | 3 ручных списка импортов → `libx.allModules` |
| 28 | refactor: автоимпорт home-manager | `home/{programs,packs,shell}/default.nix` | то же |
| 29 | refactor: overlays по файлам | `overlays/{default,blezz-pkgs,prismlauncher}.nix` | 158 строк в одном файле, `pkgs.callPackage` → `final.callPackage` |
| 30 | refactor: пути и алиасы | syncthing-папки, `nh`, secret, `home/shell/aliases.nix`, `README.md` | `/home/jenya` в 12 местах + алиасы, указывающие на несуществующий `#pc` |

## Что НЕ входит в серию

Осознанно оставлено на потом (записано в `docs/TODO.md` на шаге 22):

- `dabkrs`/`dabruks`: `builtins.currentTime` → параметр `version`/`hash`;
- локальные пакеты → `pkgs/<name>/package.nix`;
- вынос `MURMUR`/`davinci`/`tg-ws-proxy` в отдельный флейк;
- консолидация `chromium`/`firefox`/`kdeconnect` между NixOS и home-manager;
- секреты в `sops-nix`.

Причина: это меняет поведение (или требует ручной проверки сборки), а вся серия 01–30
поведение системы не меняет — кроме явно перечисленных мелочей в шагах 13 и 20.
