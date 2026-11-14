# Все оверлеи репозитория. Каждый оверлей — отдельный файл-функция final: prev: { … }.
{
  nixpkgs.overlays = [
    (import ./blezz-pkgs.nix)
    (import ./prismlauncher.nix)
    # (import ./kde-xdgdata.nix)  # см. docs/snippets/overlay_envvar.nix — выключен
  ];
}
