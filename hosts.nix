# Описание машин. Имя атрибута = hostname (networking.hostName).
#
# Используется в flake.nix через lib/mkHost, см. lib/default.nix.
{
  nixos-jenya = {
    username = "jenya";
    repoPath = "/home/jenya/nixos-pc-conf"; # путь к этому репозиторию (для `programs.nh.flake`)

    systemStateVersion = "26.05";
    homeStateVersion = "26.05";
  };
}
