{ pkgs, ... }:
{
  # Пакеты без отдельного модуля настройки.
  # Хотелки и «на попробовать» — docs/notes/packages-wishlist.md
  home.packages = with pkgs; [
    # Приложения
    obsidian
    omegat
    recoll
    sqlitebrowser
    imhex
    v2rayn
    gh
    lazygit
    gitoxide
    difftastic
    ast-grep
    coppwr
    pwgen
    zbar

    # Документы и типографика
    typst
    typstyle
    typst-live
    tinymist
    mdbook
    mdbook-admonish

    # Терминальные утилиты
    fd
    ripgrep
    jq
    tree
    file
    which
    cowsay
    aria2
    socat
    nmap
    traceroute
    colorized-logs # ansi2txt
    btop
    cpufetch
    treefmt
    nix-output-monitor
    gnutar
    gawk
    gnused
    gnupg
    nodejs_latest
    python3Packages.mutagen

    # Железо и диагностика
    lm_sensors
    pciutils # lspci
    usbutils # lsusb
    vulkan-tools
    mangohud
  ];
}
