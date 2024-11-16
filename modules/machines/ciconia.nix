###########
# Ciconia (MacOS)
#
# My work laptop.
###########
{
  inputs,
  lib,
  pkgs,
  ...
}:
{
  home-manager.users.zhauser.programs.fish = {
    interactiveShellInit = ''
      set -U NIX_CONFIG_REPO /Users/zhauser/code/personal/nix-config
    '';
  };

  # My employer's MDM system enforces a hostname based on the serial #. I don't want to collide with that, but I also
  # don't want to see it in my shell prompt.
  networking.hostName = lib.mkForce null;
  networking.computerName = lib.mkForce null;
  home-manager.users.zhauser.programs.starship.settings.hostname = {
    format = lib.mkForce "[$ssh_symbol]($style)[Ciconia]($style) in ";
  };

  environment.systemPackages = with pkgs; [ slack ];
  system.defaults.dock.persistent-apps = with pkgs; [ "${slack}/Applications/Slack.app" ];

  home-manager.users.zhauser.modules.borg.enable = true;

  home-manager.users.zhauser.programs.git.includes = [
    {
      condition = "gitdir:~/code/grammarly/";
      contentSuffix = "grammarly-gitconfig";
      contents = {
        user.email = "zach.hauser@grammarly.com";
        commit.gpgsign = false;
      };
    }
  ];

  home-manager.users.zhauser.programs.vscode = {
    extensions = with inputs.nix-vscode-extensions.extensions.${pkgs.system}.vscode-marketplace; [
      github.copilot
      thisismanta.stylus-supremacy
      redhat.vscode-yaml
      esbenp.prettier-vscode
      waderyan.gitblame
      dbaeumer.vscode-eslint
    ];
    userSettings = {
      "editor.defaultFormatter" = "esbenp.prettier-vscode";
      "[nix]" = {
        "editor.defaultFormatter" = "jnoortheen.nix-ide";
      };
      "gitblame.inlineMessageEnabled" = true;
      "gitblame.statusBarMessageFormat" = "\${author.name} (\${time.ago}): \${commit.summary}";
      "gitblame.inlineMessageFormat" = "\${author.name} (\${time.ago}): \${commit.summary}";
    };
  };
}
