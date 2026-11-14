# Анализ репозитория и план рефакторинга

Документ — результат разбора `Blezz-tech/nixos-test-pc-conf` (ветка `arena/7f961e88…`, база `a92cff8`),
`docs/TODO.md` и трёх внешних репозиториев-ориентиров.

> **Статус (этот рефакторинг выполнен):** этапы 0–3 сделаны — гигиена, `nix fmt`/CI,
> `hosts.nix` + `lib/mkHost` + `libx.allModules`, overlays разложены по файлам,
> TODO разобран на `docs/TODO.md` + `docs/notes/` + `docs/snippets/`.
> Этапы 4–7 (пакеты, дубли приложений, секреты, DX) — в `docs/TODO.md`.
> Нумерация строк в «Приложении» относится к состоянию **до** рефакторинга.
>
> **Важно про проверку.** В этой песочнице нет Nix, поэтому *ничего не собиралось*.
> Все выводы получены статическим анализом (`grep`, подсчёт строк, сверка импортов, чтение чужих репо).
> Любой пункт плана ниже надо проверять `nixos-rebuild build --flake .#nixos-jenya` + `nix flake check`.

---

## 0. TL;DR — что я бы сделал в первую очередь

| № | Действие | Эффект | Риск | Время |
|---|----------|--------|------|-------|
| 1 | Этап 0: `.gitignore`, удаление 11 неподключённых файлов, мёртвых опций, хардкода `users.jenya` | −15 % файлов, −250 строк шума | низкий | ~30 мин |
| 2 | Этап 1: `flake-parts` + `treefmt-nix` + `statix/deadnix` + GitHub Actions | появляется `nix fmt` и `nix flake check` | низкий | ~2–3 ч |
| 3 | Этап 2: `hosts.nix` + `lib/mkHost` + `username`/`homeDirectory` вместо `/home/jenya` | конфиг переносим на другую машину/юзера | низкий | ~1–2 ч |
| 4 | Этап 4: разложить `nixos/overlays.nix` (158 строк) на `overlays/*.nix` + `pkgs/` через `lib.packagesFromDirectoryRecursive` | пакеты собираются против `final`, а не «до overlay» | средний | ~3–4 ч |
| 5 | Этап 5: убрать дубли (zapret/tg-ws-proxy из `proxy-suite`, syncthing, chromium, dabkrs/dabruks) | минус ~400 строк и минус один источник багов | средний | ~2–3 ч |

Главный вывод: репозиторий **не «плохой», а неструктурированный**. Логика везде правильная,
но: 22 % строк — комментарии, 14 % файлов никем не импортируются, 9 ручных списков `imports`,
0 проверок в CI и 0 параметризации под другую машину.

---

## 1. Что есть сейчас: карта и метрики

```
flake.nix                 58   — один хост "nixos-jenya", username="jenya" (но users.jenya)
├─ nixos/                 45 файлов / 2010 строк — системные модули
│  ├─ default.nix          44   — точки входа + plasma/displayManager/portal/power
│  ├─ modules/             16 файлов: bluetooth, fonts, i18n, networking, nix, nix-ld,
│  │                              openssh (= gnupg+mtr), podman, print_and_scan, sound, tty, user...
│  ├─ programs/             6 файлов: chromium, firefox, kdeconnect, steam, (obs-studio выкл.)
│  ├─ services/            10 файлов: из них 7 не импортируются
│  ├─ pkgs/                 6 локальных пакетов (dabkrs, dabruks, davinci 314 стр., gt-vein-info,
│  │                              tg-ws-proxy, zapret-discord-youtube)
│  ├─ overlays.nix        158   — «мешок»: пакеты + таблицы версий + file:/// пути
│  ├─ packages.nix         36   — environment.systemPackages
│  ├─ config.nix           31   — кастомная опция plasma-systemmonitor (cap_net_raw)
│  ├─ proxy-suite.nix      26   — zapret + tgWsProxy из flake-инпута
│  └─ hardware-configuration.nix 121 — правленый руками (plymouth, kernelParams, ФС, amdgpu)
├─ home/                   32 файла / 1142 строки
│  ├─ programs/            12 файлов + packs/ (11 файлов-«пакетных свалок»)
│  ├─ shell/               7 файлов: alacritty, aliases (89), foot, session_vars (56), starship, zsh
│  └─ XDG/                 userDirs
├─ docs/TODO.md           308   — 167 заголовков, 5 чекбоксов
├─ treefmt.toml, cliff.toml, scripts.sh, .vscode/, imgs/ (2.1 МБ PNG/JPG)
```

Метрики:

| Метрика | Значение |
|---|---|
| `.nix` файлов | 78 |
| Строк в `.nix` | 3 225 |
| Строк, начинающихся с `#` | 731 (**22 %**) |
| Файлов, которые нигде не импортируются | **11 из 78 (14 %)** |
| Ручных списков `imports = [` | 9 |
| `environment.systemPackages` в разных файлах | 4 |
| Пакетов в `home/programs/common.nix` | 58 (из 191 строк — 108 комментарии) |
| CI / checks / devShell / formatter-выход | нет |
| `.gitignore` | **нет** |
| Коммитов в истории | 1 (история переписана — `cliff.toml` фактически не работает) |

### 1.1 Файлы, которые никто не импортирует (мёртвый код)

| Файл | Статус |
|---|---|
| `nixos/modules/vr.nix` | 43 из 51 строк закомментированы целиком |
| `nixos/modules/documentation.nix` | выключен в `nixos/modules/default.nix:6` |
| `nixos/programs/obs-studio.nix` | выключен в `nixos/programs/default.nix:6` |
| `nixos/services/postgresql.nix` | выключен в `nixos/services/default.nix:6` |
| `nixos/services/sunshine.nix` | выключен там же |
| `nixos/services/tor.nix` | выключен (18 строк, реальная конфигурация бриджей) |
| `nixos/services/v2raya.nix` | выключен |
| `nixos/services/weblate.nix` | выключен |
| `nixos/services/whoogle-search.nix` | выключен |
| `nixos/services/zapret.nix` | выключен, и логика уже есть в `proxy-suite` |
| `nixos/overlays/envvar.nix` | выключен в `nixos/overlays.nix:146` |

Плюс `nixos/modules/default.nix:17` ссылается на `./specialisation.nix`, которого не существует
(внутри комментария — но выглядит как рабочая ссылка).

---

## 2. Проблемы: симптом → место → чем грозит

### P1. `username` объявлен, но не используется (баг ожидает своего часа)
`flake.nix:33` — `username = "jenya"`, `flake.nix:37,51` — прокидывается в `specialArgs`,
но `flake.nix:49`: `users.jenya = import ./home;` — хардкод.
Переименование пользователя в одном месте даст рассинхрон HM↔система.

### P2. Абсолютные пути с `jenya` (12 активных мест)
`/home/jenya` ×6: `home/programs/syncthing.nix:13,22` (папки синка),
`nixos/programs/default.nix:28` (`programs.nh.flake`), `nixos/proxy-suite.nix:23` (`secretFile`),
`nixos/overlays.nix:125,131` (CLion-архивы);
`file:///run/media/jenya/disk_d/binfiles/...` ×6 (`nixos/overlays.nix:79-116`, MURMUR).
Конфиг нельзя собрать на другой машине и нельзя починить, не смонтировав внешний диск.

### P3. Импурити и «протухающие» хеши
* `nixos/pkgs/dabkrs/default.nix:9-18` и `dabruks`: `builtins.currentTime` внутри деривации →
  URL меняется **каждый день**, хеш зафиксирован → сборка ломается на следующий день после `nix flake update`.
  Плюс `builtins.currentTime` невозможен в pure-eval (`nix flake check`).
* `nixos/overlays.nix:79-135`: `builtins.fetchurl { url = "file:///run/media/jenya/disk_d/..."; }` —
  внешний носитель + impure fetch.
* `nixos/pkgs/davinci/default.nix:283`: `updateScript` ссылается на `pkgs/by-name/da/davinci-resolve/package.nix`,
  которого в этом репозитории нет (скопировано из nixpkgs).

### P4. Дубли и «двухголовость»
| Что | Где | Комментарий |
|---|---|---|
| zapret | `nixos/services/zapret.nix` + `nixos/pkgs/zapret-discord-youtube` + `proxy-suite` (`services.proxy-suite.zapret`) | три реализации одного |
| tg-ws-proxy | `nixos/pkgs/tg-ws-proxy` + `proxy-suite` (`tgWsProxy`) + `home/programs/packs/custom.nix:6` | пакет ставится, а сервис — из инпута |
| syncthing | `nixos/services/syncthing.nix` (24 закомментированные строки настроек + порты) и `home/programs/syncthing.nix` (те же настройки живьём) | конфиг разъехался |
| chromium | `nixos/programs/chromium.nix` (spellcheck, plasma-integration) и `home/programs/chromium.nix` (флаги, native messaging) | не очевидно, какой module главный |
| dabkrs / dabruks | 48 строк, различия — 2 слова | копипаста |
| psd | `nixos/services/default.nix:17` (`services.psd.enable`) + `home/programs/common.nix:120` (`pkgs.profile-sync-daemon`) | пакет + сервис в двух местах |
| home-manager | `nixos/packages.nix:25` (`pkgs.home-manager` в systemPackages) | HM подключён как модуль — пакет в системе не нужен |

### P5. Overlay собирает пакеты «не тем» `pkgs`
`nixos/overlays.nix:22-25,48,71` — везде `pkgs.callPackage`, хотя внутри overlay доступен `final`.
Пакет, зависящий от другого пакета из этого же overlay, получит **старую** версию из `pkgs`,
а в худшем случае — рекурсию. Правильно — `final.callPackage`.

### P6. Нет options → нет «сборочных переключателей»
Ни один модуль не имеет `options`/`mkEnableOption` (единственное исключение — `nixos/config.nix`).
Следствия: нельзя собрать урезанную конфигурацию, нельзя включать фичу «в одном месте»,
нельзя использовать `mkIf`. При этом `nixos/config.nix` заводит опцию `programs.plasma-systemmonitor.enable`,
а включает её в **другом** файле (`nixos/programs/default.nix:46`) — типичный «телепорт настроек».

### P7. Ручные списки импортов (9 штук)
`nixos/default.nix`, `nixos/modules/default.nix`, `nixos/programs/default.nix`, `nixos/services/default.nix`,
`home/default.nix`, `home/programs/default.nix`, `home/programs/packs/default.nix`, `home/shell/default.nix`,
`nixos/overlays.nix`. Каждый новый файл = правка в двух местах (создать + вписать), и именно тут
накопились 11 «забытых» файлов. Каталог `home/XDG/` при этом назван в верхнем регистре, а остальные — в нижнем.

### P8. Пакеты размазаны по 6 файлам
`nixos/packages.nix`, `nixos/modules/default.nix:49` (`wl-clipboard`), `nixos/modules/podman.nix:13`,
`nixos/modules/print_and_scan.nix:27`, `home/programs/common.nix` (58 пакетов), `home/programs/packs/*`
(10 файлов). `common.nix` — это свалка: 108 из 191 строк — закомментированные «на попробовать» пакеты.
Это же частично продублировано в `docs/TODO.md` (раздел «Добавить ПО»).

### P9. Нет линтеров/форматтера/CI
`treefmt.toml` есть, но: (а) не подключён к флейку — `nix fmt` не работает, (б) использует
`nixpkgs-fmt`, который в nixpkgs помечен как deprecated (замена — `nixfmt`/`alejandra`).
`statix`/`deadnix` не запускаются никогда, хотя именно они бы нашли: 4 неиспользуемых аргумента
(`nixos/programs/chromium.nix:1`, `nixos/services/default.nix:1`, `nixos/modules/i18n.nix:1`,
`nixos/services/postgresql.nix:2`), пустые списки (`nixos/modules/default.nix:53`
`permittedInsecurePackages = [ ]`), мёртвые `let`-биндинги.

### P10. Секреты руками
`nixos/proxy-suite.nix:23` — `secretFile = "/home/jenya/tg-ws-proxy-secret"` (файл вне репозитория,
создаётся вручную, никак не версионируется и не бэкапится). Нет `sops-nix`/`agenix`.
GPG-ключ `78E9CCD7CF92CD8F` и e-mail зашиты в `home/programs/git.nix:10`.

### P11. Нет `.gitignore`, README-инструкций, `checks`
`.gitignore` отсутствует вовсе → `result`/`result-*`/`.direnv` могут попасть в коммит (в репо уже лежат
2.1 МБ изображений — не катастрофа, но `imgs/` просится либо в LFS, либо в отдельный репозиторий обоев;
это, кстати, уже есть в TODO).
`README.md` — 9 строк без инструкции сборки.

### P12. Комментарии вместо TODO
В коде живут «хотелки» (`home/programs/common.nix`, `home/programs/packs/games.nix` — 68 из 91 строки
комментарии, `nixos/modules/networking.nix` — 48 из 58), продублированные в `docs/TODO.md`.
Нет одного источника правды: где-то «попробовать gimp» лежит в коде, где-то в TODO.

---

## 3. Чужие репозитории: что там сделано и что оттуда стоит взять

### 3.1 `ReStranger/nixos-config` (196 файлов, GPL3, обновлён 2026-11-10) — ближайший аналог

| Приём | Как реализовано | Брать? |
|---|---|---|
| `hosts.nix` — декларативный список машин | `{ nixos = { pc = { username; platform; stateVersion; isWorkstation; wm; theme; }; magicbook = …; }; }` | **да**, даже с одним хостом: это дешёвый способ отделить «железо» от «конфига» |
| `lib/mkHost` | `mkHost = machineDir: { username ? "user", … }: nixpkgs.lib.nixosSystem { specialArgs = { … }; modules = [ … ] ++ constructors; }` + `genNixos = builtins.mapAttrs mkHost` | **да** |
| `allDirs` — автоимпорт каталогов | `allDirs = dir: filter (pathType == "directory") …`; далее `imports = allDirs "${self}/modules";` | **да** — закрывает P7 |
| Модули с `options` | `options.module.tty.enable = mkEnableOption …; config = mkIf cfg.enable { … };` | **да** для новых модулей, без фанатизма |
| `overlays/` и `modules/` как каталоги + `imports = allDirs …` | один файл = один оверлей | **да** — закрывает P5 |
| `lib.packagesFromDirectoryRecursive` | `localPackages = { lib, callPackage, directory }: mapAttrs (_: v: v.default) (lib.packagesFromDirectoryRecursive { … })` | **да**, но у нас проще: переименовать `default.nix` → `package.nix` и обойтись без `mapAttrs` |
| `treefmt-nix` + `statix` + `deadnix` + `shellcheck` | `parts/treefmt/default.nix` → `nix fmt` и `nix flake check` «из коробки» | **да** — закрывает P9 |
| CI: statix + deadnix + flake-checker | `.github/workflows/checks.yml` | **да** |
| `sops-nix` + `secrets/` | секреты в репо зашифрованы, `secrets/system/pc/secrets.yaml` | **да** — закрывает P10 |
| Шаблоны `templates/module`, `templates/overlay` | `templates.default` с готовым скелетом модуля | по желанию |
| Разделение `system/machine/<host>/modules/hardware/{disks,display,gpu,kernel}` | `hardware-configuration.nix` разобран на 5 файлов | **да** — у нас 121 строка со всем подряд |

Чего у него **не** копировать: у него 3 платформы (nixos/darwin/android), 3 канала nixpkgs
(`stable`/`unstable`/`master`) и ~40 инпутов — для одной машины это лишняя сложность.

### 3.2 `spector700/Akari` (110 файлов, nixvim-конфиг) — ориентир для `neovim`

* Дерево по доменам: `config/plugins/{ai,completion,debug,editor,lang,lsp,ui,util,telescope,snacks}/…`
  + `config/plugins/default.nix` со списком импортов.
* `lib/` отдаётся в модуль через `extraSpecialArgs = import ./lib { inherit pkgs; }`
  (`lib/icons.nix`, хелпер `mkPkgs = name: src: pkgs.vimUtils.buildVimPlugin { … }`).
* `checks.default = nixvimLib.check.mkTestDerivationFromNixvimModule nixvimModule` — **конфиг
  проверяется в CI**, а не «кнутом при следующем rebuild».
* `.github/workflows/update.yml` — `DeterminateSystems/update-flake-lock` по расписанию + automerge.

Что взять: идею «`checks` на каждый крупный конфиг» и автообновление `flake.lock`.
У нас `home/programs/neovim.nix` — 10 строк (`programs.neovim.enable`), а в `docs/TODO.md`
висит «Astrovim vs Lunarvim»: если это направление живое, то через `nixvim` + `checks` его можно
держать в отдельном флейке/модуле, а не в основном конфиге.

### 3.3 `FUFSoB/proxy-suite-flake` — уже ваш инпут, но используется на 20 %

Проверено по исходникам: модуль предоставляет `services.proxy-suite.tgWsProxy`
(`modules/proxy-suite/core.nix:143`) и `zapret` (в т.ч. `zapret-discord-youtube` конфиги).
При этом в репозитории лежат собственные `nixos/pkgs/tg-ws-proxy` (73 строки) и
`nixos/pkgs/zapret-discord-youtube` + `nixos/services/zapret.nix` (134 строки), а в TODO —
«удалить модуль zapret, когда его добавят в nixpkgs».
Вывод: локальные копии — наследие, их надо удалить (это P4).

### 3.4 Общая тенденция у «однохостовых» конфигов

Почти все публичные nixos-config'и сходятся к одному каркасу:
`flake.nix (тонкий) → hosts/ или hosts.nix → lib/ (mkHost, allDirs) → modules/{nixos,home} →
pkgs/ (callPackage-директория) → overlays/ → parts/ (treefmt, checks, devshell) → secrets/`.
Полное отсутствие такого каркаса — главная причина, почему у нас 9 списков импортов и 11 забытых файлов.

---

## 4. Анализ `docs/TODO.md`

Файл: 308 строк, **167 заголовков**, **5 чекбоксов**, 10 «заборов» ```` ``` ````.

### 4.1 Сломана разметка
На строке 47 открывается блок ```` ```nix ````, который **не закрыт**: следующий ```` ``` ````
только на строке 264. Значит строки 50–263 (разделы «Проблемы», «Пакеты», «Home Manager»,
ASCII-арт и т.д.) рендерятся как один кусок кода. Плюс висячий ```` ``` ```` на 264 после git-заметки.
Отсюда и ощущение «TODO превратился в блокнот»: половина файла не отображается как текст.

### 4.2 Это не TODO, а три разных документа в одном
| Что | Строки | Куда |
|---|---|---|
| Реальные задачи | 9–20, 85–93, 121–126 | остаются в TODO как чекбоксы |
| Сниппеты/конфиги на будущее (обои, xdg.portal, activationScripts.diff, kmscon, shell.nix) | 55–172, 294–308 | `docs/snippets/*.nix` |
| Знания и ссылки (js-netfilter, .desktop-описания, cpufetch, gpg-подпись) | 254–278 | `docs/notes/*.md` |
| **Решённое** («2024.10.11 шрифты в стиме», «shell.nix with gcc optimizations») | 280–308 | `docs/notes/solved.md` (или git history) |
| ASCII-арт + функции для него | 188–252 | `docs/snippets/` (или вообще убрать) |

### 4.3 Дубли и устаревшее
* «Сделать оптимизацию» (стр. 23) и «Найти как включить отпимизациюю» (стр. 254) — одна тема дважды.
  Причём ошибка `a 'x86_64-linux' with features {gccarch-alderlake} is required…` сейчас **неактуальна**:
  `gcc.arch`/`gcc.tune` закомментированы в `nixos/hardware-configuration.nix:96-97`,
  а `system-features` — в `nixos/modules/nix.nix:22-23`. Т.е. задачу можно закрывать
  (причина ошибки: `gccarch-alderlake` требует соответствующего `system-features` у демона/билдера,
  а не только `nixpkgs.hostPlatform` — это как раз то, что описано в вашем gist).
* «Разнести конфиги из `/nixos/default`» (стр. 89) и «Перенести gt-vein-info» (стр. 85) — это
  не задачи-«пожелания», а конкретно этапы 3 и 4 этого плана. Их лучше трекать как refactor-issues.
* «Удалить модуль zapret» (стр. 19) — часть этапа 4 (P4).
* Раздел «Добавить ПО» (стр. 98–119) пересекается с `home/programs/common.nix` и `packs/games.nix`,
  где те же пакеты лежат закомментированными. Нужен один список «wishlist» — и он не в коде.

### 4.4 Предлагаемая структура

```markdown
# TODO
## Сейчас (≤ 5 пунктов, у каждого критерий готовности)
- [ ] …
## Сломанное ПО (таблица: что / почему / ссылка на issue / дата проверки)
## Задачи по рефакторингу → ссылки на GitHub Issues (этапы 0–7 см. docs/REFACTORING.md)
## Хочу попробовать (пакеты — просто список, без Nix-кода)
## Ссылки и заметки → docs/notes/
## Сниппеты → docs/snippets/
```

Правило, которое решает половину проблем: **в TODO попадает только то, что можно закрыть галочкой.**
Всё остальное — сниппет, заметка или issue.

---

## 5. План рефакторинга по этапам

Порядок выбран так, чтобы **после каждого этапа конфиг собирался** и чтобы эффект был виден сразу.

### Этап 0 — гигиена (≈30 мин, риск низкий)

1. Добавить `.gitignore`:
   ```gitignore
   result
   result-*
   .direnv/
   *.backup
   ```
2. Перенести 11 неподключённых файлов в `docs/snippets/` (не удалять — на них есть ссылки в TODO):
   `vr.nix`, `documentation.nix`, `obs-studio.nix`, `services/{postgresql,sunshine,tor,v2raya,weblate,whoogle-search,zapret}.nix`,
   `overlays/envvar.nix`.
3. Удалить мусор из кода:
   * `nixpkgs.config.permittedInsecurePackages = [ ]` (`nixos/modules/default.nix:53`);
   * `programs.kde-pim = { enable = false; … }` (`nixos/programs/default.nix:33-38`) — выключено и так;
   * закомментированные инпуты `nixvim`/`nvf`/`nur` (`flake.nix:16-25`) и `# nur` (`nixos/packages.nix:2,10`);
   * `# ./fcitx5` в `home/default.nix:9` (каталога нет);
   * `pkgs.home-manager` из `nixos/packages.nix:25`;
   * неиспользуемые аргументы: `pkgs` в `nixos/programs/chromium.nix:1`, `nixos/services/default.nix:1`,
     `nixos/modules/i18n.nix:1`, `nixos/services/postgresql.nix:2`.
4. Исправить `users.jenya` → `users.${username}` (`flake.nix:49`).
5. Переименовать `home/XDG/` → `home/xdg/` (консистентность с `programs/`, `shell/`).
6. Закомментированные «попробовать» пакеты из `common.nix`/`games.nix` перенести в TODO
   (раздел «Хочу попробовать»), в коде оставить только рабочее.

**Проверка:** `git diff --stat`, `nixos-rebuild build --flake .#nixos-jenya`.

### Этап 1 — каркас проверок: formatter, линтеры, CI (≈2–3 ч, риск низкий)

1. Добавить инпуты `flake-parts`, `treefmt-nix` (+`pre-commit-hooks` по желанию).
2. `parts/treefmt/default.nix`:
   ```nix
   { inputs, ... }: {
     imports = [ inputs.treefmt-nix.flakeModule ];
     perSystem = { ... }: {
       treefmt.config = {                       # formatter.<system> и checks.treefmt модуль создаёт сам
         projectRootFile = "flake.nix";
         programs = {
           nixfmt.enable = true;                 # замена nixpkgs-fmt
           deadnix.enable = true;                # --edit
           statix.enable = true;                 # statix fix
           shellcheck.enable = true;
           shfmt.enable = true;
           prettier.enable = true;               # md/json/yaml
           # mdformat.enable = true;             # если хочется строгий markdown
         };
         settings.global.excludes = [ "imgs/*" ];
       };
     };
   }
   ```
3. `.github/workflows/checks.yml`: `nix flake check` + `statix check .` + `deadnix --fail .` +
   `treefmt --ci` на NixOS-раннере (или `cachix/install-nix-action`).
4. `.github/workflows/update-flake-lock.yml` — по образцу Akari (раз в неделю, PR + automerge).
5. Удалить `treefmt.toml` (конфиг переезжает в flake) — иначе два источника правды.
6. Прогнать `nix fmt` один раз отдельным коммитом «chore: format», чтобы диффы не смешивались.

**Проверка:** `nix fmt && nix flake check`.

### Этап 2 — параметризация: хосты, пользователь, пути (≈1–2 ч, риск низкий)

1. `hosts.nix`:
   ```nix
   {
     nixos = {
       pc = {
         hostname = "nixos-jenya";
         username = "jenya";
         platform = "x86_64-linux";
         systemStateVersion = "26.05";
         homeStateVersion = "26.05";
         isDesktop = true;
       };
     };
   }
   ```
2. `lib/default.nix` с `mkHost` (см. §6.3) и `allDirs`.
3. `flake.nix`:
   ```nix
   nixosConfigurations = lib.genNixos hosts.nixos;
   # внутри mkHost:
   #   modules = [ … { home-manager.users.${username} = import ./home; } ];
   ```
4. Заменить `"/home/jenya"`:
   * `nixos/programs/default.nix:28` → вынести в опцию (`my.repoPath = "${home}/nixos-pc-conf"`
     в `hosts.nix`). `inputs.self.outPath` **не** подходит: это снимок в store, `nh` будет
     пересобирать старую копию;
   * `nixos/proxy-suite.nix:23` → путь из опции модуля (см. этап 6);
   * `home/programs/syncthing.nix:13,22` → `"${config.xdg.userDirs.documents}/"`,
     `"${config.xdg.userDirs.music}/"`.
5. `nixos/hardware-configuration.nix` разбить на `hardware/{filesystems,graphics,boot,kernel}.nix`
   (в духе ReStranger) — он генерируемый, но у вас уже правленый руками, так что смысла хранить
   «как сгенерировали» нет.

**Проверка:** собрать, затем временно поменять `username` на тестовый — сборка должна пройти
(или упасть только на создании юзера, но не на `users.jenya`).

### Этап 3 — структура модулей (≈4–6 ч, риск средний, делать после этапов 0–2)

Целевая раскладка — §6.1. Ключевое:

1. Ввести каталоги по смыслу: `modules/{system,desktop,hardware,security}`, `home/{programs,shell,xdg}`.
2. Переименовать «не по содержимому»:
   * `nixos/modules/openssh.nix` → `modules/programs/gnupg.nix` (+ `mtr` оттуда — в `system-packages`);
   * `nixos/config.nix` (cap_net_raw для plasma-systemmonitor) → `modules/security/wrappers.nix`,
     и там же рядом `programs.plasma-systemmonitor.enable = true`
     (сейчас опция объявлена в одном файле, а включается в `nixos/programs/default.nix:46`);
   * `nixos/default.nix` (plasma/displayManager/xdg.portal/power) → `modules/desktop/{plasma,display-manager,portal}.nix`
     (это же и в TODO, стр. 89);
   * `nixos/modules/default.nix` (bootloader, waydroid, allowUnfree, env) → разнести по
     `modules/boot.nix`, `modules/virtualisation.nix`, `modules/nixpkgs.nix`.
3. `environment.systemPackages` собрать в одном `modules/system-packages.nix`,
   остальные модули — только локальные пакеты для своих сервисов (сейчас 4 файла).
4. Новые модули писать уже с `options`/`mkEnableOption` — начиная с `desktop`, `tty`, `printing`.
5. Автоимпорт `allDirs` вместо 9 ручных списков.

**Проверка:** `nixos-rebuild build` + `nix flake check` на каждом шаге (этап 1 уже даёт эту возможность).

### Этап 4 — пакеты и overlay (≈3–4 ч, риск средний)

1. `overlays/default.nix` = `{ imports = allDirs ./.; }`, каждый overlay — файл
   (`overlays/blezz-pkgs.nix`, `overlays/prismlauncher.nix`, `overlays/kde-xdgdata.nix`).
2. Локальные пакеты: `pkgs/*/package.nix` (переименовать из `default.nix`) и
   ```nix
   # overlays/blezz-pkgs.nix
   final: prev: {
     blezz = final.callPackage
       ({ lib }: lib.packagesFromDirectoryRecursive { callPackage = final.callPackage; directory = ../pkgs; })
       { };
   }
   ```
   → `pkgs.blezz.gt-vein-info` и т.д. (`final`, а не `prev` — P5).
   Если `package.nix` переименовывать не хочется, нужен `mapAttrs (_: v: v.default)`.
3. `dabkrs` + `dabruks` → один пакет (§6.5): параметр `dictionary ? "dabruks"`,
   `date`/`version` вместо `builtins.currentTime`, `fetchurl` c фиксированным `hash`,
   раздача в `~/dicts` через `home.file` (это и есть TODO про `~/dicts/`).
4. `zdyPackages`: 7 версий × хеши — оставить актуальную (+1 запасную),
   таблицу вынести в `pkgs/zapret-discord-youtube/versions.nix`; а лучше — удалить
   (см. п. 5).
5. Удалить `pkgs/tg-ws-proxy`, `pkgs/zapret-discord-youtube`, `nixos/services/zapret.nix` —
   всё это уже есть в `proxy-suite`. Соответственно из `home/programs/packs/custom.nix` убрать
   `pkgs.blezz-pkgs.tg-ws-proxy`.
6. `davinci` (314 строк, вендоренный nixpkgs-пакет): либо жить на `pkgs.davinci-resolve`
   c overlay-патчем `studioVariant`, либо вынести в отдельный флейк `blezz-tech/nix-pkgs`
   (там же `MURMUR`, `davinci`, `gt-vein-info`). Для одной машины второй вариант лучше:
   репозиторий конфига не должен содержать 314 строк чужого кода.
7. `MURMUR.*` с `file:///run/media/...`: перенести в отдельный флейк/`requireFile`
   c локальными `srcs` **вне** репозитория (`~/binfiles`), иначе конфигурация «сборная только с флешкой».

### Этап 5 — консолидация конфигов программ (≈2–3 ч, риск средний)

Правило, которое стоит зафиксировать в README:
**система = железо, сервисы, DE, шрифты, firewall; home-manager = приложения и их настройки.**

1. `chromium`: оставить `programs.chromium` в HM (флаги + spellcheck + plasma-integration в одном файле),
   удалить `nixos/programs/chromium.nix`. Аналогично решить для `firefox`/`kdeconnect`
   (сейчас `programs.kdeconnect` в NixOS, хотя это пользовательское приложение).
2. `syncthing`: живые настройки в HM, порты — отдельный `modules/networking/firewall.nix`
   (в HM **нет** `openDefaultPorts`, поэтому порты остаются на системе);
   из `nixos/services/syncthing.nix` удалить 24 закомментированные строки, файл переименовать.
3. `psd`: либо `services.psd` в системе, либо `pkgs.profile-sync-daemon` в HM — не оба.
4. `nixos/programs/default.nix`: `programs.nh.flake` + `programs.kde-pim{…}` + `nixos/config.nix`
   — разложить; `plasma-systemmonitor` включать рядом с его опцией.
5. `nixos/modules/default.nix:36-37`: `environment.variables.EDITOR` + `sessionVariables.NIXOS_OZONE_WL`
   → `modules/environment.nix`; `waydroid` → `modules/virtualisation.nix`.

### Этап 6 — секреты (≈1 ч, риск средний)

1. `sops-nix` (+ `.sops.yaml`, `secrets/`), хранить там `tg-ws-proxy` secret.
2. `services.proxy-suite.tgWsProxy.secretFile = config.sops.secrets."tg-ws-proxy".path;`
3. Проверить, что секреты не попадают в store в открытом виде (sops-nix кладёт расшифровку в `/run`).
4. Опционально `agenix`, если не хочется `.sops.yaml`.

### Этап 7 — DX и документация (≈2 ч)

1. `devShells.default`: `nixd`, `nil`, `statix`, `deadnix`, `treefmt`, `nix-output-monitor`, `nh`.
2. `.envrc` (`use flake`) — `direnv` уже включён в HM.
3. Алиасы сборки через `nh` (он уже включён): `myBuild = "nh os switch ."`, `myBoot = "nh os boot ."`,
   вместо закомментированных `sudo nixos-rebuild switch --flake ~/nixos-pc-conf#pc`
   (в `home/shell/aliases.nix:22-26` они закомментированы и указывают на атрибут `#pc`, которого нет —
   конфигурация называется `nixos-jenya`).
4. `README.md`: структура, `nixos-rebuild switch --flake .#nixos-jenya`, где лежат секреты,
   скриншот, ссылки на `docs/REFACTORING.md` и `docs/TODO.md`.
5. `scripts.sh` в корне (дубль по смыслу с `home/shell/scripts/`) → `scripts/` с коротким README.

---

## 6. Целевое дерево и готовые сниппеты

### 6.1 Дерево

```
flake.nix                  # тонкий: инпуты + flake-parts.mkFlake + import ./parts
hosts.nix                  # описание машин (одна — тоже ок)
lib/default.nix            # allDirs, mkHost, genNixos
parts/                     # flake-parts: treefmt, checks, devshell, packages
modules/                   # общее (NixOS + HM) с options
  system/{boot,nix,nixpkgs,networking,users,fonts,i18n,sound,tty}.nix
  hardware/{filesystems,graphics,bluetooth,tablet,printing,scanner}.nix
  desktop/{plasma,display-manager,portal,power,waydroid}.nix
  security/{wrappers,gnupg}.nix
  services/{syncthing,proxy-suite,psd,fwupd}.nix
home/
  defaults.nix             # username, homeDirectory, stateVersion
  programs/…               # приложения (chromium, git, vscode, neovim, packs/…)
  shell/…
  xdg/
pkgs/                      # локальные пакеты: */package.nix
overlays/                  # по файлу на оверлей
secrets/                   # sops
docs/{TODO.md,REFACTORING.md,notes/,snippets/}
```

### 6.2 `allDirs` (закрывает P7)

```nix
# lib/default.nix
{ inputs, ... }:
rec {
  allDirs = dir:
    builtins.filter
      (path: (builtins.readFileType path) == "directory")
      (map (name: "${toString dir}/${name}") (builtins.attrNames (builtins.readDir dir)));
}
```

`imports = allDirs ./modules;` — новый файл подхватывается сам. Для `nixos/modules/default.nix`
это сразу убирает риск «создал и забыл вписать» (что уже случилось с 11 файлами).

### 6.3 `hosts.nix` + `mkHost` (закрывает P1, P2)

```nix
# lib/mkHost.nix
{ inputs }:
{ username, hostname, platform ? "x86_64-linux"
, systemStateVersion ? "26.05", homeStateVersion ? systemStateVersion
, isDesktop ? true }:
inputs.nixpkgs.lib.nixosSystem {
  specialArgs = { inherit inputs username hostname platform isDesktop; };
  modules = [
    inputs.proxy-suite.nixosModules.default
    inputs.home-manager.nixosModules.home-manager
    "${inputs.self}/modules"
    "${inputs.self}/hardware/${hostname}"
    {
      networking.hostName = hostname;
      system.stateVersion = systemStateVersion;
      home-manager = {
        useGlobalPkgs = true;
        useUserPackages = true;
        extraSpecialArgs = { inherit inputs username platform; };
        users.${username} = {
          imports = [ "${inputs.self}/home" ];
          home.stateVersion = homeStateVersion;
        };
      };
    }
  ];
}
```

### 6.4 Overlay для локальных пакетов (закрывает P5)

```nix
# overlays/blezz-pkgs.nix
final: prev: {
  blezz = final.callPackage
    ({ lib }: lib.packagesFromDirectoryRecursive {
      callPackage = final.callPackage;
      directory = ../pkgs;
    })
    { };
}
```

Требование: `pkgs/<name>/package.nix` (как в nixpkgs). Если оставить `default.nix`,
`lib.packagesFromDirectoryRecursive` вернёт `{ <name> = { default = …; }; }` и понадобится
`lib.mapAttrs (_: v: v.default)`.

### 6.5 Один пакет вместо двух словарей (закрывает P3 для dabkrs/dabruks)

```nix
# pkgs/dabruks/package.nix
{ stdenv, fetchurl, dictionary ? "dabruks", version, hash }:
stdenv.mkDerivation {
  pname = dictionary;
  inherit version;

  src = fetchurl {
    url = "https://bkrs.info/downloads/daily/${dictionary}_${version}.gz";
    inherit hash;
  };

  dontUnpack = true;
  buildPhase = ''gzip -dc < $src > $dictionary.dsl'';
  installPhase = ''
    runHook preInstall
    install -Dm644 "$dictionary.dsl" "$out/share/dicts/$dictionary-$version.dsl"
    runHook postInstall
  '';
}
```

Так `version`/`hash` — обычные параметры (обновляются `nix-update`/руками), а не «сегодняшняя дата».
Раздача в `~/dicts` — в HM:

```nix
# home/programs/dicts.nix
{ pkgs, config, ... }: {
  home.file."dicts/${pkgs.blezz.dabruks.name}.dsl".source = "${pkgs.blezz.dabruks}/share/dicts/${…}";
}
```

### 6.6 syncthing без дублей

```nix
# home/programs/syncthing.nix
{ config, ... }: {
  services.syncthing = {
    enable = true;
    overrideDevices = true;
    overrideFolders = true;
    tray.enable = true;
    settings.folders = {
      "${config.xdg.userDirs.documents}/" = { id = "5jyjs-qxyvz"; label = "документы"; devices = [ "poco-x3-pro" ]; versioning = { type = "simple"; params.keep = "50"; }; };
      "${config.xdg.userDirs.music}/"     = { id = "llhyz-w9zai"; label = "музыка";    devices = [ "poco-x3-pro" ]; versioning = { type = "simple"; params.keep = "50"; }; };
    };
  };
}

# modules/services/syncthing-ports.nix  (HM не умеет открывать порты)
{ lib, ... }: {
  networking.firewall.allowedTCPPorts = [ 22000 ];
  networking.firewall.allowedUDPPorts = [ 22000 21027 ];
}
```

---

## 7. Порядок выполнения и как проверять

| Шаг | Команда проверки |
|---|---|
| после любого этапа | `nixos-rebuild build --flake .#nixos-jenya` (сборка без активации) |
| после этапа 1 | `nix flake check`, `nix fmt -- --ci`, `nix run nixpkgs#statix -- check .` |
| после этапа 2 | временно подменить `username` в `hosts.nix` → `nixos-rebuild build` |
| после этапа 4 | `nix build .#nixosConfigurations.nixos-jenya.config.system.build.toplevel` + `nix path-info` на каждый `pkgs.blezz.*` |
| перед merge | `nix flake check && git diff --stat` |

Порядок важен: **этап 1 (checks) до этапов 3–5**, иначе структурные правки нечем валидировать.
Этапы 0–2 — почти бесплатно и не меняют поведение системы; этапы 4–5 — реально меняют дерево
замыкания, их делать по одному и с `nixos-rebuild build`.

---

## 8. Чего делать не стоит

* **Не тащить `flake-parts` «ради модности»**: он оправдан только вместе с `treefmt-nix`/`checks`/`devshell`
  (т.е. этап 1). Если не нужен — хватит `formatter.<system>` и `checks.<system>` в обычном `outputs`.
* **Не превращать `hosts.nix` в «мультихост»**: один хост — это нормально; параметризация нужна,
  чтобы пережить переустановку/смену юзера, а не чтобы хостить 5 машин.
* **Не удалять «мёртвые» файлы в никуда**: `tor.nix` (18 строк с реальными бриджами), `vr.nix`,
  `documentation.nix` — в `docs/snippets/`, иначе потеряется знание.
* **Не менять `stateVersion`** и не «оптимизировать» `gcc.arch` в `hardware-configuration.nix`,
  пока не настроены `system-features` у билдера (иначе вернётся та самая ошибка из TODO).
* **Не смешивать форматирование и логику в одном коммите**: сначала `chore: nixfmt`, потом правки —
  иначе `git blame` станет бесполезным.
* **Не хранить секреты в store** без sops/agenix: `secretFile` должен указывать в `/run/secrets/...`.
* **Не заводить второй flake с пакетами, пока не закончен этап 4**: распил на `blezz-tech/nix-pkgs`
  имеет смысл только после того, как `pkgs/` уже приведён в порядок.

---

## 9. Ожидаемый эффект (оценка)

| Показатель | Сейчас | После этапов 0–2 | После 0–5 |
|---|---|---|---|
| `.nix` файлов | 78 | 67 | ~60 |
| Строк `.nix` | 3 225 | ~2 950 | ~2 500 |
| Файлов вне импортов | 11 | 0 | 0 |
| Ручных `imports`-списков | 9 | 9 | 1–2 |
| Хардкод путей с `jenya` | 12 | 12 | 0 |
| Импуре Pure-eval (`currentTime` ×2, `file://` ×8) | 10 | 10 | 0 |
| Проверки в CI | 0 | 3 (fmt/statix/deadnix + flake check) | + build |
| `nix fmt` работает | нет | да | да |

---

## Приложение: быстрые ссылки на проблемные места

| Файл:строка | Что |
|---|---|
| `flake.nix:33,49` | `username` vs `users.jenya` |
| `flake.nix:16-25` | закомментированные инпуты |
| `nixos/overlays.nix:22-25` | `pkgs.callPackage` внутри overlay |
| `nixos/overlays.nix:32-46` | таблица из 7 версий zapret |
| `nixos/overlays.nix:79-135` | `file://` пути (MURMUR, CLion) |
| `nixos/pkgs/dabkrs/default.nix:9-18` | `builtins.currentTime` + ежедневный хеш |
| `nixos/pkgs/dabruks/default.nix:9-18` | копия предыдущего |
| `nixos/pkgs/davinci/default.nix:283` | `updateScript` от nixpkgs |
| `nixos/services/default.nix:1-14` | неиспользуемый `pkgs`, 7 выключенных импортов |
| `nixos/services/syncthing.nix:6-24` | дубль настроек из HM |
| `nixos/config.nix:12-30` | опция без своего включения |
| `nixos/modules/default.nix:53` | пустой `permittedInsecurePackages` |
| `nixos/modules/nix.nix:22-23` | закомментированные `gccarch/gcctune` (отсюда ошибка в TODO) |
| `nixos/packages.nix:25` | `pkgs.home-manager` в системе |
| `nixos/programs/default.nix:28` | `/home/jenya/...` в `programs.nh.flake` |
| `nixos/proxy-suite.nix:23` | секрет в `$HOME` |
| `home/programs/syncthing.nix:13,22` | `/home/jenya` в путях папок |
| `home/programs/common.nix` | 58 пакетов, 108 строк комментариев |
| `home/shell/aliases.nix:22-26` | закомментированные `nixos-rebuild … #pc` (атрибута нет) |
| `docs/TODO.md:47` | незакрытый блок ```` ```nix ```` |
| `docs/TODO.md:23,254` | дубль темы «оптимизация» |
| `docs/TODO.md:280-308` | «решённое» внутри TODO |
