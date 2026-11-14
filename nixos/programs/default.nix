# Точка входа системных «программ» (модули programs.*).
{ libx, ... }:
{
  imports = libx.allModules ./.;
}
