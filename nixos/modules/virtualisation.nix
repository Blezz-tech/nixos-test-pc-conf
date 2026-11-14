{ pkgs, ... }:
{
  # Эмулятор Android
  virtualisation.waydroid.enable = true;
  virtualisation.waydroid.package = pkgs.waydroid-nftables;

  # Менеджер виртуальных машин (выключен, раскомментировать при использовании)
  # virtualisation.libvirtd.enable = true;
  # programs.virt-manager.enable = true;
}
