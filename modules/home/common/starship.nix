{
  programs.starship = {
    enable = true;

    enableFishIntegration = true;

    settings = {
      hostname = {
        ssh_only = false;
      };

      username.show_always = true;

      os = {
        disabled = false;
        style = "bold black";
        # Nerd Font symbols (probably won't render otherwise).
        symbols.Macos = " ";
        symbols.NixOS = " ";
      };

      shlvl = {
        disabled = false;
      };

      status.disabled = false;
    };
  };
}
