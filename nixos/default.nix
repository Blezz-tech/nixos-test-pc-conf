# Общая часть конфигурации: её получает каждая машина.
# Графическая часть — в nixos/workstation/ (подключают только рабочие станции),
# машинное — в nixos/hosts/<имя>/.
{ ... }:
{
  imports = [
    ./modules
    ./services
    ./programs
    ./overlays
    ./packages.nix
    ./proxy-suite.nix
  ];

  time.timeZone = "Europe/Moscow";

  system.stateVersion = "26.05";

  # environment.shellInit = ''
  #   export XDG_DATA_DIRS=$(echo $XDG_DATA_DIRS | tr ':' '\n' | sort | uniq | tr '\n' ':')
  #   export QT_PLUGIN_PATH=$(echo $QT_PLUGIN_PATH | tr ':' '\n' | sort | uniq | tr '\n' ':')
  #   export XDG_CONFIG_DIRS=$(echo $XDG_CONFIG_DIRS | tr ':' '\n' | sort | uniq | tr '\n' ':')
  #   export NIXPKGS_QT6_QML_IMPORT_PATH=$(echo $NIXPKGS_QT6_QML_IMPORT_PATH | tr ':' '\n' | sort | uniq | tr '\n' ':')
  # '';
}
