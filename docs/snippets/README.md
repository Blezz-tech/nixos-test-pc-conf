# Архив выключенных модулей

Здесь лежат куски конфигурации, которые **не подключены** к системе: либо модуль целиком
закомментирован, либо его импорт убран из `default.nix`. Файлы не собираются и ни на что не
влияют — они сохранены только как заготовка на будущее.

Правило: если блок кода не работает и не планируется в ближайшее время, он живёт здесь,
а не в дереве `nixos/` или `home/`. Там должен быть только действующий конфиг.

| Файл | Что внутри | Почему выключено |
|------|------------|------------------|
| `vr.nix` | `programs.alvr`, `services.monado`, `services.wivrn`, окружение XR-рантайма | 43 из 51 строки закомментированы; импорт убран из `nixos/modules/default.nix`. VR-шлема нет |
| `documentation-off.nix` | `documentation.{enable,doc,info,man,nixos}.enable = false` | отключает man-страницы и `nixos-help`; импорт убран из `nixos/modules/default.nix`, чтобы не терять справку |
| `tor.nix` | `services.tor` с `enable = true` | импорт отключён: tor-клиент с obfs4-мостом не используется |
| `postgresql.nix` | `services.postgresql` + `ensureDatabases`/`ensureUsers` | импорт отключён: локальная БД не используется |
| `sunshine.nix` | `services.sunshine.enable` (сервер стриминга) | импорт отключён: стриминг не настроен |
| `obs-studio.nix` | `programs.obs-studio` + плагины `wlrobs`, `obs-backgroundremoval` | импорт отключён: OBS не установлен ни в NixOS, ни в home-manager |

Вернуть в работу: скопировать файл обратно в исходный каталог (`nixos/modules/`, `nixos/services/`
или `nixos/programs/`) и добавить импорт в соответствующий `default.nix`.
