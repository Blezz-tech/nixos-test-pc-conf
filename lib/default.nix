# Обвязка хоста и мелкие помощники для модулей.
# flake.nix должен быть оглавлением (входы → хосты → выходы), а как именно
# собирается NixOS-конфигурация — дело этого файла.
{ inputs }:

let
  lib = inputs.nixpkgs.lib;

  libx = {
    # Рекурсивно собирает все .nix-файлы каталога, кроме default.nix.
    # Заменяет ручные оглавления: добавил файл рядом — он подключён,
    # забыть дописать строку в список невозможно.
    allModules =
      dir:
      let
        entries = builtins.readDir dir;
        collect =
          name:
          let
            type = entries.${name};
            path = dir + "/${name}";
          in
          if type == "directory" then
            libx.allModules path
          else if
            type == "regular"
            && lib.hasSuffix ".nix" name
            && name != "default.nix"
            # hardware-configuration.nix генерируется nixos-generate-config и
            # подключается явно через optionalModules — иначе он приедет дважды
            && name != "hardware-configuration.nix"
          then
            [ path ]
          else
            [ ];
      in
      lib.concatMap collect (builtins.attrNames entries);

    # Каталог подключается только если он есть: у машины может не быть своих
    # модулей, у пользователя — своих домашних.
    optionalModules = path: lib.optional (builtins.pathExists path) path;

    # mkHost "nixos-jenya" { username = "jenya"; homeManager = true; }
    #   → nixosConfiguration
    #
    # Собирается из трёх частей:
    #   1. ../nixos — общая часть, одинаковая у всех машин;
    #   2. ../nixos/hosts/<name>/ — машинное: hardware-configuration.nix,
    #      отличия по железу и программам (подключается, если каталог есть);
    #   3. home-manager + ../home — если homeManager = true.
    #
    # name уходит в specialArgs как hostName (его читают
    # nixos/modules/networking.nix и home/default.nix)
    # и в users.<name> у home-manager.
    mkHost =
      name:
      {
        system ? "x86_64-linux",
        username,
        homeManager ? true,
        modules ? [ ],
        ...
      }:
      lib.nixosSystem {
        inherit system;

        specialArgs = {
          inherit inputs libx username;
          hostName = name;
        };

        modules =
          [
            inputs.proxy-suite.nixosModules.default
            ../nixos
          ]
          ++ libx.optionalModules (../nixos/hosts + "/${name}")
          ++ lib.optionals homeManager [
            inputs.home-manager.nixosModules.home-manager
            {
              home-manager = {
                useGlobalPkgs = true;
                useUserPackages = true;
                users.${username} = import ../home;
                extraSpecialArgs = {
                  inherit inputs libx username;
                  hostName = name;
                };
              };
            }
          ]
          ++ modules;
      };
  };
in
libx
