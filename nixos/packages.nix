{ pkgs, ... }:
{
  # Общесистемные пакеты. Приложения пользователя — в home/programs/.
  #
  # NOTE: pkgs.home-manager здесь не нужен — home-manager подключён как модуль.
  # NOTE: pkgs.kdePackages.partitionmanager не нужен — его ставит
  #       programs.partition-manager (nixos/programs/system.nix).
  environment.systemPackages = with pkgs; [
    # Диски и восстановление данных
    testdisk-qt
    ddrescue
    ext4magic
    ntfs3g

    # Базовые утилиты
    xdg-utils
    git
    wget
    wget2
    curl
    wireguard-tools
    lzip # for waydroid
    libdecor

    # Аудио/видео
    vlc

    # Запуск сторонних бинарников
    steam-run
  ];
}
