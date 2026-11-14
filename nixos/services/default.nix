{ pkgs
, ...
}: {
  imports = [
    ./fwupd.nix
    ./syncthing.nix
    # ./v2raya.nix
    # ./weblate.nix
    # ./whoogle-search.nix
    # ./zapret.nix
  ];

  services.psd = {
    enable = true;
    resyncTimer = "15m";
  };
}
