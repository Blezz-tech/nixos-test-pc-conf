# Пакеты уровня системы: нужно каждой машине, включая сервер. Пользовательские
# приложения живут в home/programs/, те, у которых есть модуль NixOS, — в
# nixos/programs/, а чисто графические — в nixos/workstation/packages.nix.
{ pkgs, ... }: {
  environment.systemPackages = [
    # Диагностика и восстановление дисков
    pkgs.ddrescue # побитовое копирование с обходом бэд-блоков
    pkgs.ext4magic # восстановление удалённых файлов ext4

    # Базовые сетевые и файловые утилиты (есть в консоли)
    pkgs.curl
    pkgs.wget
    pkgs.wget2
    pkgs.git
    pkgs.wireguard-tools # wg / wg-quick
    pkgs.ntfs3g # монтирование NTFS (в т.ч. раздел Windows)
    pkgs.lzip # waydroid: распаковка образа

    # CLI home-manager. Не дубль: HM подключён как NixOS-модуль, а в этом режиме
    # он сам CLI не ставит — в home-manager/modules/programs/home-manager.nix
    # установка идёт под условием !submoduleSupport.enable
    pkgs.home-manager
  ];
}
