{ pkgs, ... }:
{
  # Установленные игры/лаунчеры. Список «попробовать» — docs/notes/packages-wishlist.md
  home.packages = with pkgs; [
    # wine & proton
    protonup-qt

    # Лаунчеры
    prismlauncher
    bottles
    ftb-app
    r2modman
  ];
}
