# Оглавление модулей NixOS. Здесь должны быть только импорты: сам конфиг живёт
# в файлах рядом, по одному на тему.
{ ... }: {
  imports = [
    ./bluetooth.nix
    ./boot.nix
    ./environment.nix
    ./fonts.nix
    ./gnupg.nix
    ./i18n.nix
    ./mtr.nix
    ./networking.nix
    ./nix-ld.nix
    ./nix.nix
    ./nixpkgs.nix
    ./opentablet.nix
    ./plasma-systemmonitor.nix
    ./podman.nix
    ./print_and_scan.nix
    ./sound.nix
    ./tty.nix
    ./user.nix
    ./virtualisation.nix
  ];
}
