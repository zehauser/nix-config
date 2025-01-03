{
  home.file.".config/ghostty/config".text = ''
    auto-update = off

    font-family = "Hack Nerd Font Mono"

    theme = "light:zehauser-light,dark:zehauser-dark"

    cursor-style = bar
    adjust-cursor-thickness = 150%

    keybind = "global:alt+space=toggle_visibility"
    keybind = "global:alt+shift+space=toggle_quick_terminal"
  '';

  home.file.".config/ghostty/themes/zehauser-light".text = ''
    background = #ffffff
    foreground = #111111

    selection-background = #b5d5ff
    selection-foreground = #000000

    cursor-color = #000000

    palette = "0=#212121"
    palette = "1=#c30771"
    palette = "2=#10a778"
    palette = "3=#a89c14"
    palette = "4=#008ec4"
    palette = "5=#523c79"
    palette = "6=#20a5ba"
    palette = "7=#e0e0e0"
    palette = "8=#212121"
    palette = "9=#fb007a"
    palette = "10=#5fd7af"
    palette = "11=#f3e430"
    palette = "12=#20bbfc"
    palette = "13=#6855de"
    palette = "14=#4fb8cc"
    palette = "15=#f1f1f1"
  '';

  home.file.".config/ghostty/themes/zehauser-dark".text = ''
    background = #000000
    foreground = #ffffff

    selection-background = #b5d5ff
    selection-foreground = #ffffff

    cursor-color = #000000

    palette = "0=#616161"
    palette = "1=#ff8272"
    palette = "2=#b4fa72"
    palette = "3=#fefdc2"
    palette = "4=#a5d5fe"
    palette = "5=#ff8ffd"
    palette = "6=#d0d1fe"
    palette = "7=#f1f1f1"
    palette = "8=#8e8e8e"
    palette = "9=#ffc4bd"
    palette = "10=#d6fcb9"
    palette = "11=#fefdd5"
    palette = "12=#c1e3fe"
    palette = "13=#ffb1fe"
    palette = "14=#e5e6fe"
    palette = "15=#feffff"
  '';

  home.file.".hushlogin".text = "";
}
