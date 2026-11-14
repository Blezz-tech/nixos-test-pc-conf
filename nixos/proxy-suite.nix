{ config, username, ... }:
{
  services.proxy-suite = {
    enable = true;

    zapret = {
      enable = true;
      zapret-discord-youtube = {
        configName = "general(FAKE_TLS_AUTO_ALT3)"; # the default; try others if it does not work
        domains = [
          "rutracker.org"
          "protondb.com"
          "www.protondb.com"
          "steamdb.info"
          "click.redditmail.com"
          "forgejo.org"
          # "discovery-announce-v4.syncthing.net"
          # "relays.syncthing.net"
          # "forum.syncthing.net"
        ]; # more sites to unblock
      };
    };

    tgWsProxy = {
      enable = true;
      # TODO: переехать на sops-nix (docs/REFACTORING.md, этап 6)
      secretFile = "${config.users.users.${username}.home}/tg-ws-proxy-secret";
    };
  };
}
