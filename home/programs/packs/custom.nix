{ pkgs, ... }:
{
  # Локальные пакеты из nixos/overlays/blezz-pkgs.nix
  home.packages = with pkgs.blezz-pkgs; [
    discord-krisp-patcher
    tg-ws-proxy
  ];
}
