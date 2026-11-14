{ pkgs, ... }:
let
  # Python со «стандартным» набором библиотек
  python-custom = pkgs.python313.withPackages (
    python-pkgs: with python-pkgs; [
      numpy
      pandas
      scipy
      sympy
      matplotlib
      beautifulsoup4
      python-lsp-server
      black # formatter
    ]
  );
in
{
  home.packages = with pkgs; [
    # Python
    python-custom

    # C/C++
    clang
    clang-analyzer

    # Lua
    lua
    luarocks

    # Rust
    cargo
    rustc
    rustfmt
    rust-analyzer
    uv

    # Nix
    nix-search
    nixd # LSP
    nil # LSP
    nixfmt # форматтер (nixpkgs-fmt устарел)
    statix
    deadnix
    nufmt # nushell

    # Сборка
    gnumake

    # LSP
    marksman # markdown
    typescript-language-server # js/typescript
    vscode-langservers-extracted # css eslint html json markdown
    yaml-language-server # yaml
    bash-language-server # bash
  ];
}
