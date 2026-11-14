{ pkgs, ... }:
{
  # Переменные окружения
  environment.variables.EDITOR = "nvim";
  environment.sessionVariables.NIXOS_OZONE_WL = "1"; # wayland для electron приложений

  # Общий буфер обмена в wayland
  environment.systemPackages = [ pkgs.wl-clipboard ];
}
