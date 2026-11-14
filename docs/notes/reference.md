# Заметки и ссылки

Знание, которое раньше лежало комментариями в конфигах.

## Блокировка рекламы Яндекса через /etc/hosts

Полный список (был закомментирован в `nixos/modules/networking.nix`).
Сейчас включена только одна запись (`127.0.0.1 mc.yandex.ru`), остальное — по желанию:

```nix
networking.extraHosts = ''
  0.0.0.0 advertising.yandex.ru
  0.0.0.0 www.advertising.yandex.ru
  0.0.0.0 audience.yandex.ru
  0.0.0.0 www.audience.yandex.ru
  0.0.0.0 direct.yandex.ru
  0.0.0.0 www.direct.yandex.ru
  0.0.0.0 metrika.yandex.ru
  0.0.0.0 www.metrika.yandex.ru
  0.0.0.0 partner.yandex.ru
  0.0.0.0 www.partner.yandex.ru
  0.0.0.0 yandexdatafactory.com
  0.0.0.0 www.yandexdatafactory.com
  0.0.0.0 partner.yandex.ua
  0.0.0.0 www.partner.yandex.ua
  0.0.0.0 metrika.yandex.ua
  0.0.0.0 www.metrika.yandex.ua
  0.0.0.0 metrica.yandex.com
  0.0.0.0 www.metrica.yandex.com
  0.0.0.0 metrica.yandex.ru
  0.0.0.0 www.metrica.yandex.ru
  0.0.0.0 clck.yandex.ru
  0.0.0.0 www.clck.yandex.ru
  0.0.0.0 mc.yandex.ru
  0.0.0.0 www.mc.yandex.ru
  0.0.0.0 yabs.yandex.ru
  0.0.0.0 www.yabs.yandex.ru
  0.0.0.0 yabs.yandex.ua
  0.0.0.0 www.yabs.yandex.ua
  0.0.0.0 an.yandex.ru
  0.0.0.0 www.an.yandex.ru
  0.0.0.0 an.yandex.ua
  0.0.0.0 www.an.yandex.ua
  0.0.0.0 3ds.money.yandex.ru
  0.0.0.0 abo.market.yandex.ru
  0.0.0.0 bs.yandex.ru
  0.0.0.0 click.yandex.ru
  0.0.0.0 partner.market.yandex.ru
  0.0.0.0 www.adv.yandex.ru
  0.0.0.0 yandex-question.naydex.net
  0.0.0.0 naydex.net
  0.0.0.0 yandexadexchange.net
'';
```

## js-netfilter

<https://github.com/NixOS/nixpkgs/issues/194114#issuecomment-1859954277>

## Русские описания для .desktop файлов приложений

Идея: переопределять `desktopItems`/`makeDesktopItem` с русским `comment`/`genericName`.
Пока не реализовано.

## Команды

Вывод информации о процессоре:

```bash
cpufetch -F --accurate-pp --measure-max-freq --logo-short -v
```

## Оптимизация под конкретный процессор (gcc.arch/gcc.tune)

Гайд: <https://gist.github.com/Blezz-tech/07db8fc68ab57ff844ae795bcf0c28f8>

Суть: `nixpkgs.hostPlatform.gcc.arch` заставляет собирать пакеты с `-march=…`,
а значит деривации требуют системную фичу `gccarch-<arch>`. Её должен объявить
**тот демон/билдер**, который собирает (`nix.settings.system-features`), иначе:

```
error: a 'x86_64-linux' with features {gccarch-alderlake} is required to build …, but I am …
```

Поэтому включать `gcc.arch` нужно одновременно:
1. `nixpkgs.hostPlatform.gcc.arch/tune` в конфигурации,
2. `nix.settings.system-features = [ "gccarch-alderlake" "gcctune-alderlake" ]`,
3. и после `nixos-rebuild` (потому что во время сборки используется текущий nix.conf).

Сейчас в репозитории всё это закомментировано:
`nixos/hardware-configuration.nix` (`nixpkgs.hostPlatform`) и `nixos/modules/nix.nix` (`system-features`).

Пример шелла с оптимизацией — `docs/snippets/shell-gcc-optimized.nix`.

## Метод ввода fcitx5

Заготовка (была закомментирована в `nixos/modules/i18n.nix`) — `docs/snippets/input-method-fcitx5.nix`.

## XDG MIME

Было закомментировано в `nixos/modules/default.nix`:

```nix
# xdg.mime.enable = true;
# xdg.mime.addedAssociations = {
#   "application/drawio" = "drawio.desktop";
# };
```

Стоит проверить: сначала с закомментированным `xdg.portal`, потом с
`xdg.portal.extraPortals = [ pkgs.kdePackages.xdg-desktop-portal-kde ];`
(snippet — `docs/snippets/xdg-portal.nix`).

## kmscon

Альтернатива системной консоли, заготовка — `docs/snippets/kmscon.nix`.

## keyd

Попробовать как замену/дополнение к раскладке: <https://github.com/rvaiya/keyd>

## AstroVim vs LunarVim

Сравнить и выбрать. Если делать neovim на nixvim — см. `spector700/Akari`:
`config/plugins/**` по доменам + `checks.default`, чтобы конфиг проверялся в CI.
