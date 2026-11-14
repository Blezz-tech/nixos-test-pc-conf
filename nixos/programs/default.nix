# Оглавление программ NixOS. Здесь должны быть только импорты.
{ ... }: {
  imports = [
    ./chromium.nix
    ./firefox.nix
    ./kdeconnect.nix
    ./steam.nix
    ./system.nix
  ];
}
