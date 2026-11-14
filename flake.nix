{
  description = "Jenya NixOS Flake Configuration";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";

    proxy-suite.url = "github:FUFSoB/proxy-suite-flake";
    proxy-suite.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs =
    {
      self,
      nixpkgs,
      home-manager,
      proxy-suite,
      ...
    }@inputs:
    let
      inherit (nixpkgs) lib;

      libx = import ./lib { inherit inputs; };
      hosts = import ./hosts.nix;

      systems = [ "x86_64-linux" ];
      forAllSystems = lib.genAttrs systems;
      pkgsFor = system: nixpkgs.legacyPackages.${system};

      # инструменты, нужные `nix fmt`
      formatterTools =
        pkgs:
        with pkgs;
        [
          treefmt
          nixfmt
          deadnix
          statix
          shfmt
        ];
    in
    {
      # Все машины из hosts.nix
      nixosConfigurations = libx.genNixos hosts;

      # nix fmt
      formatter = forAllSystems (
        system:
        let
          pkgs = pkgsFor system;
        in
        pkgs.writeShellApplication {
          name = "treefmt";
          runtimeInputs = formatterTools pkgs;
          text = ''
            exec treefmt "$@"
          '';
        }
      );

      # nix develop
      devShells = forAllSystems (
        system:
        let
          pkgs = pkgsFor system;
        in
        {
          default = pkgs.mkShell {
            packages = (formatterTools pkgs) ++ (with pkgs; [
              nh
              nix-output-monitor
              git
            ]);
          };
        }
      );

      # Проверяется только то, что конфигурация вообще вычисляется (eval errors,
      # конфликты опций) — без сборки всей системы.
      # Полная сборка: nix build .#nixosConfigurations.nixos-jenya.config.system.build.toplevel
      checks = forAllSystems (
        system:
        let
          pkgs = pkgsFor system;

          # Линтеры (statix/deadnix) гоняются в CI: сначала нужно один раз
          # прогнать `nix fmt`, иначе они законно падают на старом форматировании.
          evalNixos =
            hostname: host:
            pkgs.runCommandLocal "eval-${hostname}" { } ''
              echo ${host.config.system.build.toplevel.drvPath} > $out
            '';
        in
        builtins.mapAttrs evalNixos self.nixosConfigurations
      );
    };
}
