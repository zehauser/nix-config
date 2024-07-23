{
  services.espanso = {
    enable = true;
    configs = {
      default = {
        search_shortcut = "ALT+CTRL+SPACE";
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
