{
  imports = [
    ./chromium.nix
    ./firefox.nix
    ./kdeconnect.nix
    ./steam.nix
  ];

  # programs.throne = {
  #   enable = true;
  #   tunMode.enable = true;
  # };

  # programs.zoom-us.enable = true;

  # Чтобы не было ошибок
  programs.dconf.enable = true;

  # Менеджер разделов
  programs.partition-manager.enable = true;

  # Для ГПУ AMD 
  programs.corectrl.enable = true;

  # nix helper
  programs.nh.enable = true;
  programs.nh.flake = "/home/jenya/nixos-pc-conf/";

  # plasma6 ставит programs.kde-pim.enable = mkDefault true (nixpkgs/nixos/modules/
  # services/desktop-managers/plasma6.nix), и тогда прилетает весь KDE PIM:
  # akonadi, kmail, kontact, korganizer, akregator (~178 МиБ). Явный false это
  # перекрывает. Без этой строки набор пакетов системы вырастет.
  programs.kde-pim.enable = false;

  # appimage-run
  programs.appimage.enable = true;
  programs.appimage.binfmt = true;

  # openvpn client
  # programs.openvpn3.enable = true;

  # plasma-systemmonitor
  programs.plasma-systemmonitor.enable = true;
}
