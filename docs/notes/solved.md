# Решённые проблемы

История. Новые пункты — сверху, с датой.

## 2024.10.11 — шрифты в Steam

Проблема решена: шрифты в Steam отображаются.

```nix
programs.steam.fontPackages
```

> Font packages to use in Steam.
>
> Defaults to system fonts, but could be overridden to use other fonts — useful
> for users who would like to customize CJK fonts used in Steam. According to the
> [upstream issue](https://github.com/ValveSoftware/steam-for-linux/issues/10422#issuecomment-1944396010),
> Steam only follows the per-user fontconfig configuration.

## Ошибка `gccarch-alderlake` при оптимизации

Причина и решение — `docs/notes/reference.md` («Оптимизация под конкретный процессор»).
Сейчас `gcc.arch`/`gcc.tune` закомментированы, ошибка не воспроизводится.

## Git: не нужно подписывать каждый коммит

> Since commits contain cryptographic hashes of their parents all the way back to
> the beginning of the repo history, signing the last commit is equivalent to
> signing all of the commits.

Достаточно подписывать последний коммит (`git commit -S`).
