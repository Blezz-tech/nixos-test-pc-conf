# Системная часть Chromium (интеграция с Plasma и проверка орфографии).
# Пользовательская часть — home/programs/chromium.nix.
{
  programs.chromium = {
    enable = true;
    extraOpts = {
      "SpellcheckEnabled" = true;
      "SpellcheckLanguage" = [
        "en-US"
        "ru"
        "zh-CN"
      ];
    };
    enablePlasmaBrowserIntegration = true;
  };
}
