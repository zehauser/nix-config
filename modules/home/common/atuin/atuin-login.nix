{
  config,
  helpers,
  pkgs,
  ...
}:
let
  # At the time of writing, `atuin login` only reads input from /dev/tty, so we can't just redirect stdin.
  #
  # The exact text matches specified in this expect script will be super brittle, but the advantage of that is we'll
  # get an early warning if `atuin login` is changed or improved.
  atuinLogin = pkgs.writeShellScript "atuin-login" ''
    ${pkgs.expect}/bin/expect -f ${pkgs.writeText "atuin-login.exp" ''
      set timeout 2
      set password [exec ${pkgs.coreutils}/bin/cat ${config.sops.secrets.atuin_password.path}]

      spawn ${pkgs.atuin}/bin/atuin login -u zhauser

      expect {
        "You are already logged in!" {
          exit 0
        }
        -exact "Please enter password: " {
          send "$password\n"
        }
        timeout { puts "timeout!"; exit 1 }
      }

      expect {
        -exact {Please enter encryption key [blank to use existing key file]: } {
          send "\n"
        }
        timeout { puts "timeout!"; exit 1 }
      }

      expect {
        eof {}
        timeout { puts "timeout!"; exit 1 }
      }
    ''}
    echo "Done Expect script!"
  '';

  atuinSecretsReadyScript =
    let
      checkScript = pkgs.writeShellScript "atuin-secrets-ready" ''
        [[ -e "${config.sops.secrets.atuin_password.path}" && -e "${config.sops.secrets.atuin_key.path}" ]]
        exit $?
      '';
    in
    ''
      echo "Waiting for Atuin SOPS secrets to become available... (start: $(${pkgs.coreutils}/bin/date))"
      ${pkgs.retry}/bin/retry -d 1 -t 10 -- ${checkScript}
    '';
in
{
  systemd.user.services.atuin-login = helpers.mkIfNixos {
    Unit.Requires = [ "sops-nix.service" ];
    Unit.After = [ "sops-nix.service" ];
    Service.Type = "oneshot";
    Service.RemainAfterExit = "true";
    Service.ExecStart = toString atuinLogin;
    Install.WantedBy = [ "default.target" ];
  };

  # I think there's a native launchd equivalent to systemd's dependency graph (at least for certain use cases, like
  # waiting for a file, which is all we're doing here), but I haven't explored it yet.
  launchd.agents.atuin-login = helpers.mkIfMacos {
    enable = true;

    config = {
      Program = toString (
        pkgs.writeShellScript "atuin-login" ''
          ${atuinSecretsReadyScript}
          ${atuinLogin}
        ''
      );
      KeepAlive = false;
      RunAtLoad = true;
      StandardOutPath = "${config.home.homeDirectory}/Library/Logs/atuin-login-script/stdout";
      StandardErrorPath = "${config.home.homeDirectory}/Library/Logs/atuin-login-script/stderr";
    };
  };

  sops.secrets.atuin_password = { };
}
