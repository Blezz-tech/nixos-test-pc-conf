{ pkgs, ... }:
{
  home.packages = with pkgs; [
    discord-canary
    discord
    vesktop
    telegram-desktop
    thunderbird
  ];
}
