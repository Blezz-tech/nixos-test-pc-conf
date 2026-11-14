{
  nix = {
    optimise.automatic = true;

    settings = {
      experimental-features = [
        "nix-command"
        "flakes"
      ];

      # Фичи билдера. Нужны, если включать nixpkgs.hostPlatform.gcc.arch/tune —
      # см. docs/notes/reference.md («Оптимизация под конкретный процессор»).
      system-features = [
        # "gccarch-alderlake"
        # "gcctune-alderlake"
        "benchmark"
        "big-parallel"
        "kvm"
        "nixos-test"
      ];

      # substituters/trusted-public-keys для своего кэша добавлять здесь
    };

    gc = {
      automatic = true;
      dates = "weekly";
      options = "--delete-older-than 30d";
    };
  };
}
