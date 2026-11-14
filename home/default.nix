{ username, homeStateVersion ? "26.05", ... }:
{
  imports = [
    ./programs
    ./shell
    ./xdg
  ];

  home = {
    inherit username;
    homeDirectory = "/home/${username}";
    stateVersion = homeStateVersion;
  };

  # Let home Manager install and manage itself.
  programs.home-manager.enable = true;
}
