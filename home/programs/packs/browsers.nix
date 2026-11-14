{ pkgs, ... }:
{
  home.packages = with pkgs; [
    google-chrome
    tor-browser
    vivaldi
  ];
}
