{
  username,
  hostName,
  libx,
  ...
}:
{
  imports = [
    ./programs
    ./shell
    ./xdg
  ]
  ++ libx.optionalModules (./hosts + "/${hostName}");

  home = {
    username = "${username}";
    homeDirectory = "/home/${username}";
    stateVersion = "26.05";
  };

  # Let home Manager install and manage itself.
  programs.home-manager.enable = true;
}
