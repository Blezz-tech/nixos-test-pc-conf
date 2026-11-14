# Пакеты «на попробовать»

Списки, которые раньше жили закомментированными строками в Nix-файлах.
Правило: в коде — только то, что реально установлено; здесь — идеи.

Чтобы что-то поставить: добавить в подходящий `home/programs/packs/*.nix`
(или `nixos/packages.nix`) и удалить строку отсюда.

## Приложения и утилиты (были закомментированы в `common.nix`)

Источник: `home/programs/common.nix`

- `pkgs.git-sim`
- `pkgs.wpsoffice`
- `pkgs.rstudio`
- `pkgs.whatsapp-for-linux`
- `pkgs.dorion`
- `pkgs.code-cursor`
- `pkgs.graphviz`
- `pkgs.notepad-next`
- `pkgs.tiled`
- `pkgs.unityhub`
- `pkgs.ihp-new`
- `pkgs.cachix`
- `pkgs.vengi-tools`
- `pkgs.ldtk`
- `pkgs.easyocr`
- `pkgs.rhvoice`
- `pkgs.speechd`
- `pkgs.figma-linux`
- `pkgs.age`
- `pkgs.sops`
- `pkgs.far2l`
- `pkgs.crow-translate`
- `pkgs.zim`
- `pkgs.stack`
- `pkgs.kando`
- `pkgs.activate-linux`
- `pkgs.distrobox`
- `pkgs.baobab`
- `pkgs.cura`
- `pkgs.cura-appimage`
- `pkgs.nextcloud-client`
- `pkgs.nextcloud-talk-desktop`
- `pkgs.geogebra6`
- `pkgs.okteta`
- `pkgs.digikam`
- `pkgs.rawtherapee`
- `pkgs.go`
- `pkgs.git-spice`
- `pkgs.mdbook-epub`
- `pkgs.mdbook-pdf`
- `pkgs.calibre`
- `pkgs.gpu-viewer`
- `pkgs.github-desktop`
- `pkgs.zotero`
- `pkgs.just`
- `pkgs.eaglemode # Весёлый файловый менеджер с разными минииграми`
- `pkgs.helix`
- `pkgs.scc`
- `pkgs.cloc`
- `pkgs.rustdesk-flutter`
- `pkgs.anilibria-winmaclinux`
- `pkgs.haruna`
- `pkgs.treesheets`
- `pkgs.parsec-bin`
- `pkgs.remmina`
- `pkgs.goldendict-ng`
- `pkgs.dig`
- `pkgs.nekoray`
- `pkgs.flameshot`
- `pkgs.mysql-workbench`
- `pkgs.dbeaver-bin`
- `pkgs.zeal-qt6`
- `pkgs.anki`
- `pkgs.rars`
- `pkgs.freecad-wayland`
- `pkgs.openscad`
- `pkgs.openscad-lsp`
- `pkgs.kicad`
- `pkgs.zig`
- `pkgs.sfxr`
- `pkgs.sfxr-qt`
- `pkgs.archivebox`
- `pkgs.openapi-generator-cli`
- `pkgs.postman`
- `pkgs.neofetch`
- `pkgs.nnn # terminal file manager`
- `pkgs.utils`
- `pkgs.yq-go # yaml processer https://github.com/mikefarah/yq`
- `pkgs.mtr # A network diagnostic tool`
- `pkgs.iperf3`
- `pkgs.dnsutils # `dig` + `nslookup``
- `pkgs.ldns # replacement of `dig`, it provide the command `drill``
- `pkgs.ipcalc # it is a calculator for the IPv4/v6 addresses`
- `pkgs.productivity`
- `pkgs.hugo # static site generator`
- `pkgs.glow # markdown previewer in terminal`
- `pkgs.iotop # io monitoring`
- `pkgs.iftop # network monitoring`
- `pkgs.strace # system call monitoring`
- `pkgs.ltrace # library call monitoring`
- `pkgs.lsof # list open files`
- `pkgs.sysstat`
- `pkgs.lm_sensors # for `sensors` command`
- `pkgs.ethtool`

## Архиваторы

Источник: `home/programs/packs/archive.nix`

- `pkgs.rar`
- `pkgs.runzip # Fixing zip archives`
- `pkgs.ventoy-full`

## home/programs/packs/custom.nix

Источник: `home/programs/packs/custom.nix`

- `pkgs.blezz-pkgs.davinci-resolve`
- `pkgs.blezz-pkgs.MURMUR.CLION.v2025_2_2`

## Языки и тулинг

Источник: `home/programs/packs/dev.nix`

- `pkgs.haskell.packages.ghc9122.cabal-install`
- `pkgs.haskell.packages.ghc9122.haskell-language-server`
- `pkgs.haskell.packages.ghc9122.hlint`
- `pkgs.haskell.packages.ghc9122.ghc`
- `pkgs.ghciwatch`
- `pkgs.gcc`
- `pkgs.cmake`
- `pkgs.agda`
- `pkgs.rocq-core`
- `pkgs.coqPackages.vscoq-language-server # coq/rocq`
- `pkgs.nodePackages_latest.prettier`

## Игры, лаунчеры, мод-менеджеры

Источник: `home/programs/packs/games.nix`

- `pkgs.nexusmods-app-unfree`
- `pkgs.ryubing`
- `pkgs.shadps4`
- `pkgs.lutris`
- `pkgs.itch`
- `pkgs.limo`
- `pkgs.vcmi`
- `pkgs.fheroes2`
- `pkgs.vangers`
- `pkgs.openxray`
- `pkgs.arx-libertatis`
- `pkgs.opengothic`
- `pkgs.cataclysm-dda`
- `pkgs.ruffle`
- `pkgs.superTuxKart`
- `pkgs.cmatrix`
- `pkgs.keeperrl`
- `pkgs.minetest`
- `pkgs.wesnoth`
- `pkgs.openspades`
- `pkgs.airshipper`
- `pkgs.taisei`
- `pkgs.unciv`
- `pkgs.endless-sky`
- `pkgs.openra`
- `pkgs.osu-lazer-bin`
- `pkgs.the-powder-toy`
- `pkgs.crawlTiles`
- `pkgs.hedgewars`
- `pkgs.tome4`
- `pkgs.warzone2100`
- `pkgs.tome4`
- `pkgs.openspades`
- `pkgs.openclonk`
- `pkgs.opentyrian`
- `pkgs.simutrans`
- `pkgs.redeclipse`
- `pkgs.openrct2`
- `pkgs.openttd`
- `pkgs.stuntrally`
- `pkgs.neverball`
- `pkgs.widelands`
- `pkgs.warsow`
- `pkgs.urbanterror`
- `pkgs.iagno`
- `pkgs.shorter-pixel-dungeon`
- `pkgs.summoning-pixel-dungeon`
- `pkgs.experienced-pixel-dungeon`
- `pkgs.rat-king-adventure`
- `pkgs.rkpd2`
- `pkgs.shattered-pixel-dungeon`
- `pkgs.kdePackages.kolf`
- `pkgs.kdePackages.kmahjongg`
- `pkgs.kdePackages.knights`
- `pkgs.kdePackages.knavalbattle`
- `pkgs.kdePackages.kmines`
- `pkgs.kdePackages.picmi`
- `pkgs.kdePackages.ksudoku`
- `pkgs.kdePackages.kpat`
- `pkgs.kdePackages.ksirk`
- `pkgs.kdePackages.kajongg`
- `pkgs.kdePackages.kwordquiz`

## KDE-приложения

Источник: `home/programs/packs/kde.nix`

- `pkgs.kdePackages.kolourpaint`
- `pkgs.kdePackages.kasts`
- `pkgs.kdePackages.juk`
- `pkgs.kdePackages.kalzium`
- `pkgs.kdePackages.kfind`
- `pkgs.kdePackages.ksystemlog`
- `pkgs.kdePackages.kio-gdrive`
- `pkgs.kdePackages.kcharselect`
- `pkgs.kdePackages.wallpaper-engine-plugin`
- `pkgs.kdePackages.neochat`
- `pkgs.kdePackages.kdenlive`

## Графика, музыка, видео

Источник: `home/programs/packs/media.nix`

- `pkgs.blender-hip`
- `pkgs.musescore`
- `pkgs.gimp`
- `pkgs.inkscape`
- `pkgs.krita`
- `pkgs.aseprite`
- `pkgs.anime4k`
- `pkgs.audacity`
- `pkgs.openai-whisper # транскрибация аудио в текст`
- `pkgs.auto-editor`

## Мессенджеры

Источник: `home/programs/packs/messengers.nix`

- `pkgs.element-desktop`
- `pkgs.discord-screenaudio`
- `pkgs.webcord-vencord`
- `pkgs.nheko`
- `pkgs.fractal`
- `pkgs.revolt-desktop`

## PDF и TeX

Источник: `home/programs/packs/tex.nix`

- `pkgs.texlive.combined.scheme-full`
- `pkgs.ocrmypdf`
- `pkgs.tesseract`
- `pkgs.pdfarranger`

## Из docs/TODO.md

### Пакеты, которых нет в nixpkgs (надо пакетировать)

- `bilibili`
- `qq`
- `wechat-uos` (license.tar.gz можно взять из репозитория archlinux)
- `stirling-pdf`
- `stepik-oauth2-videodownloader` — <https://github.com/StepicOrg/stepik-oauth2-videodownloader>

### Просто проверить

- `qqwing`, `smassh`, `p7zip`, `media-downloader`, `kdePackages.krdc`,
  `kdePackages.kate`, `kdePackages.yakuake`, `aha`, `clinfo`, `wayland-utils`,
  `nim`, `nimlsp`, `eglinfo`
- САПР: `cadzinho`, `librecad`, `kompass3d`
- KDE: `KColorChooser`, `KolourPaint`, `KGpg`, `Kompare`, `Skanlite`, `Sweeper`,
  `Elisa`, `KTimer`, `KCachegrind`, `Kamoso`, `KGeography`, `KMouseTool`,
  `KGet`, `Marble`, `KDiamond`, `Kookbook`


## Конфиги, вынесенные из кода

- PHP с расширениями (`php83` + composer/codesniffer) — `docs/snippets/php.nix`
- Haskell-тулинг (ghc9122, HLS, hlint, ghciwatch) — был закомментирован в `dev.nix`
- `myPHP`/`python-custom`-подобные сборки — держать в `home/programs/packs/dev.nix`,
  если понадобятся
