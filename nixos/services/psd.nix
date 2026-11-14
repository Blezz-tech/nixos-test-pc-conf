{
  # Profile-sync-daemon: держит профиль браузера в RAM
  services.psd = {
    enable = true;
    resyncTimer = "15m";
  };
}
