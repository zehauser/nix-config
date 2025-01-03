{ inputs, ... }:
{
  services.espanso = {
    enable = true;
    package = inputs.nixpkgs-macos-stable.legacyPackages.aarch64-darwin.espanso;
    configs = {
      default = {
        search_shortcut = "ALT+CTRL+SHIFT+SPACE";
      };
    };
    matches = {
      base = {
        matches = [
          {
            trigger = ":date";
            replace = "{{date}}";
          }
          {
            trigger = ":dawn";
            replace = "🌅";
          }
          {
            trigger = ":excl";
            replace = "❗️";
          }
          {
            trigger = ":flag";
            replace = "🚩";
          }
          {
            trigger = ":smile";
            replace = "🙂";
          }
          {
            trigger = ":tornado";
            replace = "🌪️";
          }
          {
            trigger = ":p0";
            replace = "⚫️";
          }
          {
            trigger = ":p1";
            replace = "🔴";
          }
          {
            trigger = ":p2";
            replace = "🟠";
          }
          {
            trigger = ":p3";
            replace = "🟡";
          }
          {
            trigger = ":p4";
            replace = "🟢";
          }
        ];
        global_vars = [
          {
            name = "date";
            type = "date";
            params = {
              format = "%Y-%m-%d";
            };
          }
        ];
      };
    };
  };
}
