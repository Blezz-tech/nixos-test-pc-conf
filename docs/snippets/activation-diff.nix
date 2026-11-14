# Заготовка из docs/TODO.md: показывать diff замыкания при activate.
#
# Требует `supportsDryActivation`, чтобы работать в `nixos-rebuild dry-activate`.
{ pkgs, ... }:
{
  system.activationScripts.diff = {
    supportsDryActivation = true;
    text = ''
      if [[ -e /run/current-system ]]; then
        ${pkgs.nix}/bin/nix store diff-closures /run/current-system "$systemConfig"
      fi
    '';
  };
}
