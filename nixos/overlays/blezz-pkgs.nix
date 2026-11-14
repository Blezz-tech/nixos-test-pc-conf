# Локальные пакеты репозитория (бывший nixos/overlays.nix).
#
# Собираются через `final.callPackage`, чтобы зависеть от результатов
# предыдущих оверлеев, а не от «pre-overlay» pkgs.
#
# TODO(рефакторинг): переехать на nixpkgs-раскладку `pkgs/<name>/package.nix`
# + `lib.packagesFromDirectoryRecursive` (см. docs/REFACTORING.md, этап 4).
final: prev: {
  blezz-pkgs = {
    dabkrs = final.callPackage ../pkgs/dabkrs { };
    dabruks = final.callPackage ../pkgs/dabruks { };
    gt-vein-info = final.callPackage ../pkgs/gt-vein-info { };
    tg-ws-proxy = final.callPackage ../pkgs/tg-ws-proxy { };

    # nixpkgs'ый zapret + конфиги fake из zdy (нужно для proxy-suite)
    zapret = prev.zapret.overrideAttrs (old: {
      postInstall =
        (old.postInstall or "")
        + ''
          mkdir -p $out/files/
          cp -r $src/files/fake/ $out/files/
        '';
    });

    # Конфиги Flowseal/zapret-discord-youtube по версиям.
    # TODO(рефакторинг): оставить одну актуальную версию, остальные — в отдельный
    # файл/репо (сейчас 7 версий = 7 FOD'ов и лишний eval).
    zdyPackages =
      let
        versions = [
          {
            name = "1_7_2b";
            zdy_version = "1.7.2b";
            zdy_hash = "sha256-59kG0UA+zUkpL/ZOwjSEpOlGJspgI8bQapxdv/FvzX8=";
          }
          {
            name = "1_8_0";
            zdy_version = "1.8.0";
            zdy_hash = "sha256-GgDxB2GFnQizvY2kiBs7E9lgvxn4KwxRcOZBAeUXCPk=";
          }
          {
            name = "1_8_3";
            zdy_version = "1.8.3";
            zdy_hash = "sha256-xpq/I9oOhgl7i7tRMsj9P/ka6rvdMfGt88VxGwOPDLM=";
          }
          {
            name = "1_8_5";
            zdy_version = "1.8.5";
            zdy_hash = "sha256-paT29uftOnbViXM1X5aX7p6cKNrFDUCRX7Pjp/+TyO8=";
          }
          {
            name = "1_9_7";
            zdy_version = "1.9.7";
            zdy_hash = "sha256-n+V3/jE4L2fUKognR/LOssMELWAY+9tguP/TZX6TOCE=";
          }
          {
            name = "1_10_1";
            zdy_version = "1.10.1";
            zdy_hash = "sha256-LPV9ruCAznU8LL7wT+KMt0fECGMUP+8qo1r5PxqMYxs=";
          }
          {
            name = "1_10_4";
            zdy_version = "1.10.4";
            zdy_hash = "sha256-5qKg2BvW4XcjY+Az9ocvwACcfsfBpG4I3Xh6SCPksIM=";
          }
        ];
      in
      builtins.listToAttrs (
        map (v: {
          name = v.name;
          value = final.callPackage ../pkgs/zapret-discord-youtube {
            zdy_version = v.zdy_version;
            zdy_hash = v.zdy_hash;
          };
        }) versions
      );

    discord-krisp-patcher = final.writers.writePython3Bin "discord-krisp-patcher" {
      libraries = with final.python3Packages; [
        capstone
        pyelftools
      ];
      flakeIgnore = [
        "E501" # line too long (82 > 79 characters)
        "F403" # 'from module import *' used; unable to detect undefined names
        "F405" # name may be undefined, or defined from star imports: module
      ];
    } (builtins.readFile ../pkgs/discord-krisp-patcher/main.py);

    davinci-resolve = final.callPackage ../pkgs/davinci {
      studioVariant = true;
    };

    # Локальные сборки MURMUR из tar.gz на внешнем диске.
    #
    # ВНИМАНИЕ: `file://` пути — impure, конфигурация собирается только на этой
    # машине и только при смонтированном диске. Планируется вынос в отдельный
    # флейк с `requireFile` (docs/REFACTORING.md, этап 4).
    MURMUR = {
      IDEA = {
        v2022_3_3 = final.jetbrains.idea-ultimate.overrideAttrs (_: {
          src = builtins.fetchurl {
            url = "file:///run/media/jenya/disk_d/binfiles/MURMUR-IDEA-2022.3.3.tar.gz";
            sha256 = "sha256:19hlac1xlc31vdrf3sl20kw90mfsl29qwgh31wdyymlanj2bs0n3";
          };
        });

        v2024_2_1 = final.jetbrains.idea-ultimate.overrideAttrs (_: {
          src = builtins.fetchurl {
            url = "file:///run/media/jenya/disk_d/binfiles/MURMUR-IDEA-2024.2.1.tar.gz";
            sha256 = "sha256:0v9nc7n9xyzrmqlqi4shlnl4gijqcf1f84b26m6q2nxdrwqp90da";
          };
        });
      };

      PHP = {
        v2022_3_3 = final.jetbrains.phpstorm.overrideAttrs (_: {
          src = builtins.fetchurl {
            url = "file:///run/media/jenya/disk_d/binfiles/MURMUR-PHP-2022.3.3.tar.gz";
            sha256 = "sha256:1a9fvjqnz93w5czsj7zf3j1nmq3107mhiwsgxxnb31gv5l1nd6np";
          };
        });

        v2024_2_1 = final.jetbrains.phpstorm.overrideAttrs (_: {
          src = builtins.fetchurl {
            url = "file:///run/media/jenya/disk_d/binfiles/MURMUR-PHP-2024.2.1.tar.gz";
            sha256 = "sha256:00f0n80wazyqilmdi26zfa7xhjsq8c1lyjrjcmdx0p41fnc53px9";
          };
        });

        v2025_1_1 = final.jetbrains.phpstorm.overrideAttrs (_: {
          src = builtins.fetchurl {
            url = "file:///run/media/jenya/disk_d/binfiles/MURMUR-PHP-2025.1.1.tar.gz";
            sha256 = "sha256:18znpgjlk8740p7j2dfs5jmdw5k0f4bzd2lpaikmdf2xf7m24ixn";
          };
        });

        v2025_2_1 = final.jetbrains.phpstorm.overrideAttrs (_: {
          src = builtins.fetchurl {
            url = "file:///run/media/jenya/disk_d/binfiles/MURMUR-PHP-2025.2.1.tar.gz";
            sha256 = "sha256:076fwkfdyi7v3ng9fy4cx479kdvza5s54g5c6cdxqinf380vp1qh";
          };
        });
      };

      CLION = {
        v2025_2_2 = final.jetbrains.clion.overrideAttrs (_: {
          src = builtins.fetchurl {
            url = "file:///home/jenya/CLion-2025.2.2.tar.gz";
            sha256 = "sha256:01h6fd8yz9q7b51nfyha7cpnfjdrsvgk925j8dkmhqrshlf4zf27";
          };
        });

        v2025_2_1 = final.jetbrains.clion.overrideAttrs (_: {
          src = builtins.fetchurl {
            url = "file:///home/jenya/CLion-2025.2.1.tar.gz";
            sha256 = "sha256:0j06cdb8r9na0f5hqfwqf535c8k25a6dqwkxvgpm5xkja4g1l3pm";
          };
        });
      };
    };
  };
}
