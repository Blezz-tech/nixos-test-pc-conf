{ config, ... }:
{
  # Порты в фаерволе открываются на системном уровне:
  # nixos/modules/networking.nix (home-manager этого не умеет).
  services.syncthing = {
    enable = true;
    overrideDevices = true;
    overrideFolders = true;
    tray.enable = true;

    settings = {
      devices = {
        "pc-nixos-jenya" = {
          id = "JHDYZX7-3T6D53O-5XH5VO6-ASLUYIO-5KMGYO7-6JRYWPH-LFUDSBW-SLVLUAY";
        };
        "poco-x3-pro" = {
          id = "RU33CWR-HPTNESJ-6DELDQQ-FZ2ERPA-W3TYRJH-N64ELRJ-YXUFKG6-ABSHRAX";
        };
      };

      folders = {
        "${config.xdg.userDirs.documents}/" = {
          id = "5jyjs-qxyvz";
          label = "документы";
          devices = [ "poco-x3-pro" ];
          versioning = {
            type = "simple";
            params.keep = "50";
          };
        };

        "${config.xdg.userDirs.music}/" = {
          id = "llhyz-w9zai";
          label = "музыка";
          devices = [ "poco-x3-pro" ];
          versioning = {
            type = "simple";
            params.keep = "50";
          };
        };
      };
    };
  };
}
