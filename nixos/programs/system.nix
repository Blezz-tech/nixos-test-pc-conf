# Общие системные programs.*, не относящиеся к конкретному приложению.
{ repoPath, ... }:
{
  # Чтобы не было ошибок
  programs.dconf.enable = true;

  # Менеджер разделов
  programs.partition-manager.enable = true;

  # Для ГПУ AMD
  programs.corectrl.enable = true;

  # nix helper
  programs.nh = {
    enable = true;
    flake = repoPath;
  };

  # appimage-run
  programs.appimage = {
    enable = true;
    binfmt = true;
  };
}
