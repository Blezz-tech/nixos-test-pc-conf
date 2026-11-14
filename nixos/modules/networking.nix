{
  networking = {
    firewall.enable = true;
    networkmanager.enable = true;
    # nftables.enable = true;
    # hostName задаётся в hosts.nix (lib/mkHost)
  };

  # Локальная «заглушка» для рекламы/метрик яндекса
  networking.extraHosts = ''
    127.0.0.1 mc.yandex.ru
  '';

  # Syncthing: сам клиент настраивается в home/programs/syncthing.nix,
  # но home-manager не умеет открывать порты в фаерволе.
  networking.firewall.allowedTCPPorts = [ 22000 ];
  networking.firewall.allowedUDPPorts = [
    22000
    21027
  ];

  # Полный список доменов для блокировки рекламы — см. docs/notes/reference.md
}
