# PHP с расширениями (было в home/programs/packs/dev.nix, но не использовалось).
#
# Чтобы включить — раскомментировать в home/programs/packs/dev.nix:
#   myPHP.php
#   myPHP.php.packages.composer
#   myPHP.php.packages.php-codesniffer
{ pkgs, ... }:
let
  myPHP.php = pkgs.php83.withExtensions (
    { enabled, all }:
    enabled
    ++ [
      all.bcmath
      all.tokenizer
      all.curl
      all.gd
      all.intl
      all.mbstring
      all.zip
      all.sqlite3
      all.pdo_mysql
      all.mysqli
      all.redis
    ]
  );
in
{
  home.packages = [
    myPHP.php
    myPHP.php.packages.composer
    myPHP.php.packages.php-codesniffer
  ];
}
