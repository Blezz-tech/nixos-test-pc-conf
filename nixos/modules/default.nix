{ pkgs
, ...
}: {
  imports = [
    ./bluetooth.nix
    ./boot.nix
    ./environment.nix
    ./fonts.nix
    ./gnupg.nix
    ./i18n.nix
    ./mtr.nix
    ./networking.nix
    ./nix-ld.nix
    ./nix.nix
    ./opentablet.nix
    ./podman.nix
    ./print_and_scan.nix
    ./sound.nix
    ./tty.nix
    ./user.nix
  ];

  # Эмулятор Android
  virtualisation.waydroid.enable = true;
  virtualisation.waydroid.package = pkgs.waydroid-nftables;

  # nixpkgs settings
  nixpkgs.config.allowUnfree = true;
  # nixpkgs.config.rocmSupport = true;

  # Enable touchpad support (enabled default in most desktopManager).
  # libinput.enable = true;

  # MIME TYPE
  # xdg.mime.enable = true;
  # xdg.mime.addedAssociations = {
  #   "application/drawio" = "drawio.desktop";
  # };
}
