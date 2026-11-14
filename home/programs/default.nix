# Оглавление домашних программ: по файлу на приложение, плюс тематические
# наборы в packs/.
{ ... }: {
  imports = [
    ./chromium.nix
    ./common.nix
    ./direnv.nix
    ./easyeffects.nix
    ./eza.nix
    ./fzf.nix
    ./git.nix
    ./neovim.nix
    ./nushell.nix
    ./syncthing.nix
    ./v2rayn.nix
    ./vscode.nix

    ./packs
  ];
}
