{ username, ... }:
{
  imports = [
    ./modules
    ./services
    ./programs
    ./hardware-configuration.nix
    ./overlays
    ./packages.nix
    ./proxy-suite.nix
  ];

  time.timeZone = "Europe/Moscow";
  # system.stateVersion задаётся в hosts.nix (lib/mkHost).

  # xdg_open should work in steam_run this way… well it’s not
  # https://github.com/NixOS/nixpkgs/issues/160923
  xdg.portal = {
    enable = true;
    xdgOpenUsePortal = true;
  };

  services.desktopManager.plasma6.enable = true;

  services.displayManager = {
    plasma-login-manager.enable = true;
    autoLogin = {
      enable = true;
      user = username;
    };
  };

  powerManagement.enable = true;
  powerManagement.cpuFreqGovernor = "performance";
}
