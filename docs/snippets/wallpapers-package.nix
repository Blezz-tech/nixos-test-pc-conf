# Пакет с обоями (было закомментировано в docs/TODO.md).
#
# Идея: репозиторий Blezz-tech/wallpapers как derivation, а home-manager
# делает симлинк в xdg.userDirs.pictures.
#
# TODO: сделать пакет доступным пользователю (симлинк в ~/media/images/pkgs/).
{ stdenv, fetchFromGitHub }:
stdenv.mkDerivation (finalAttrs: {
  name = "blezz-tech-wallpapers";
  version = "v0.1";

  src = fetchFromGitHub {
    owner = "Blezz-tech";
    repo = "wallpapers";
    rev = finalAttrs.version;
    hash = "sha256-AUH32T5mH6bXtwGXv/vuuYK5BDgOQ1SMjZKXh6WDPqw=";
  };

  buildPhase = ''cp -pr $src/ $out/'';

  meta.description = "My wallpapers";
})
