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
          else if type == "regular" && lib.hasSuffix ".nix" name && name != "default.nix" then
            [ path ]
          else
            [ ];
      in
      lib.concatMap collect (builtins.attrNames entries);

    # mkHost "nixos-jenya" { username = "jenya"; role = "workstation"; }
    #   → nixosConfiguration
    #
    # name уходит в specialArgs как hostName (его читает
    # nixos/modules/networking.nix) и в users.<name> у home-manager.
    # role выбирает профиль: nixos/profiles/<role>.nix.
    # Машинная часть (nixos/hosts/<name>/) подключается, если каталог есть.
    mkHost =
      name:
      {
        system ? "x86_64-linux",
        username,
        role ? "workstation",
        modules ? [ ],
        # `...` — потому что запись реестра несёт ещё и enabled: фильтрует его
        # libx.enabledHosts, самому mkHost он не нужен.
        ...
      }:
      lib.nixosSystem {
        inherit system;

        specialArgs = {
          inherit
            inputs
            libx
            username
            role
            ;
          hostName = name;
        };

        modules = [
          # nixvim.nixosModules.nixvim
          # nvf.nixosModules.default
          # nur.modules.nixos.default
          inputs.proxy-suite.nixosModules.default

          # общая часть и профиль роли
          ../nixos
          ../nixos/profiles/${role}.nix
        ]
        ++ lib.optional (builtins.pathExists (../nixos/hosts + "/${name}")) (../nixos/hosts + "/${name}")
        ++ [
          inputs.home-manager.nixosModules.home-manager
          {
            home-manager = {
              useGlobalPkgs = true;
              useUserPackages = true;
              users.${username} = import ../home;
              extraSpecialArgs = {
                inherit inputs libx username;
              };
            };
          }
        ]
        ++ modules;
      };

    # Только включённые хосты: у остальных ещё нет hardware-configuration.nix.
    enabledHosts = builtins.filterAttrs (_: host: host.enabled or true);
  };
in
libx
