{ ... }: {
  imports = [
    ./fwupd.nix
    ./syncthing.nix
  ];

  services.psd = {
    enable = true;
    resyncTimer = "15m";
  };
}
