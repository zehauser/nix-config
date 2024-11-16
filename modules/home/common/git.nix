{
  config,
  helpers,
  pkgs,
  ...
}:
{
  programs.git = {
    enable = true;

    userName = "Zach Hauser";
    userEmail = "zehauser@gmail.com";

    aliases = {
      co = "checkout";
      st = "status";
      br = "branch";
    };

    ignores = helpers.mkIfMacos [
      "*~"
      ".DS_Store"
    ];

    extraConfig =
      let
        signingKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIHgZVKMHfw9xlWKAT7iXSKhDazevVbIa1m9GiyLv85wg";
      in
      {
        init.defaultBranch = "main";
        push.autoSetupRemote = true;
        core.editor = helpers.mkIfMacos "subl -w";
        rebase.autoSquash = true;

        diff.colorMoved = "default";
        diff.algorithm = "histogram";
        branch.sort = "-committerdate";
        tag.sort = "taggerdate";
        merge.conflictstyle = "zdiff3";
        commit.verbose = false;
        rerere.enabled = true;
        help.autocorrect = "prompt";
        transfer.fsckobjects = true;
        fetch.fsckobjects = true;
        receive.fsckobjects = true;

        core.pager = "${pkgs.delta}/bin/delta";
        interactive.diffFilter = "${pkgs.delta}/bin/delta --color-only";
        delta.navigate = true;

        credential.helper = helpers.mkIfNixos "store --file ${config.sops.secrets.git_credentials.path}";

        # I haven't yet got to configuring this to also work on NixOS yet. But I generally commit from my laptop.
        gpg.ssh.program = "/Applications/1Password.app/Contents/MacOS/op-ssh-sign";
        commit.gpgsign = true;
        tag.gpgsign = true;
        user.signingkey = signingKey;
        gpg.format = "ssh";
        gpg.ssh.allowedSignersFile = toString (
          pkgs.writeText "allowed-signers" ''
            ${config.programs.git.userEmail} namespaces="git" ${signingKey}
          ''
        );
      };
  };

  sops.secrets.git_credentials = helpers.mkIfNixos { };
}
