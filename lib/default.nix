# Хелперы для flake.nix и модулей.
#
# libx попадает в модули NixOS через specialArgs, в модули home-manager —
# через extraSpecialArgs (см. mkHost ниже).
{ inputs }:
let
  inherit (builtins)
    attrNames
    filter
    readDir
    ;
  inherit (inputs.nixpkgs.lib)
    hasSuffix
    ;

  # Все модули из каталога → список путей для `imports`.
  #
  # Берёт:
  #   * файлы *.nix (кроме default.nix),
  #   * подкаталоги, у которых есть свой default.nix.
  #
  # Позволяет писать `{ imports = libx.allModules ./.; }` и не держать
  # в голове список файлов: новый модуль подхватывается сам.
  # dir — путь-литерал (./foo) либо абсолютная строка ("${self}/foo").
  allModules =
    dir:
    let
      names = attrNames (readDir dir);
      isModuleFile = name: hasSuffix ".nix" name && name != "default.nix";
      isModuleDir = name: builtins.pathExists (dir + "/${name}/default.nix");
      isDir = name: (builtins.readFileType (dir + "/${name}")) == "directory";
    in
    map (name: dir + "/${name}") (
      filter (name: isModuleFile name || (isDir name && isModuleDir name)) names
    );

  libx = {
    inherit allModules;

    # Собирает nixosSystem из описания в hosts.nix.
    mkHost =
      hostname: host:
      let
        username = host.username;
        systemStateVersion = host.systemStateVersion or "26.05";
        homeStateVersion = host.homeStateVersion or systemStateVersion;
        # путь к этому репозиторию (для `nh`, скриптов и т.п.)
        repoPath = host.repoPath or "/home/${username}/nixos-pc-conf";
      in
      inputs.nixpkgs.lib.nixosSystem {
        specialArgs = {
          inherit
            inputs
            libx
            hostname
            username
            repoPath
            ;
        };

        modules = [
          inputs.proxy-suite.nixosModules.default
          inputs.home-manager.nixosModules.home-manager

          ../nixos

          {
            networking.hostName = hostname;
            system.stateVersion = systemStateVersion;

            home-manager = {
              useGlobalPkgs = true;
              useUserPackages = true;

              extraSpecialArgs = {
                inherit
                  inputs
                  libx
                  hostname
                  username
                  homeStateVersion
                  ;
              };

              # home.stateVersion задаётся внутри home/default.nix
              users.${username}.imports = [ ../home ];
            };
          }
        ];
      };

    # { pc = {...}; laptop = {...}; } -> { pc = nixosConfiguration; ... }
    genNixos = hosts: builtins.mapAttrs (hostname: host: libx.mkHost hostname host) hosts;
  };
in
libx
