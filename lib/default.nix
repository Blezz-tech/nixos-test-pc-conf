# Обвязка хоста: всё, что раньше лежало в flake.nix одним куском.
# flake.nix должен быть оглавлением (входы → хосты → выходы), а как именно
# собирается NixOS-конфигурация — дело этого файла.
{ inputs }:

{
  # mkHost "nixos-jenya" { username = "jenya"; } → nixosConfiguration
  #
  # name уходит в specialArgs как hostName (его читает
  # nixos/modules/networking.nix) и в users.<name> у home-manager.
  mkHost =
    name:
    {
      system ? "x86_64-linux",
      username,
      modules ? [ ],
    }:
    inputs.nixpkgs.lib.nixosSystem {
      inherit system;

      specialArgs = {
        inherit inputs username;
        hostName = name;
      };

      modules = [
        # nixvim.nixosModules.nixvim
        # nvf.nixosModules.default
        # nur.modules.nixos.default
        inputs.proxy-suite.nixosModules.default
        ../nixos
        inputs.home-manager.nixosModules.home-manager
        {
          home-manager = {
            useGlobalPkgs = true;
            useUserPackages = true;
            users.${username} = import ../home;
            extraSpecialArgs = {
              inherit inputs username;
            };
          };
        }
      ]
      ++ modules;
    };
}
