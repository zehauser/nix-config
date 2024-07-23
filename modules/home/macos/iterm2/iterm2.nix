{ pkgs, ... }:
let
  setDefaultProfile =
    pkgs.writers.writePython3 "set-default-profile-iterm2" { libraries = [ pkgs.python3Packages.iterm2 ]; }
      ''
        import iterm2


        async def main(connection):
            all_profiles = await iterm2.PartialProfile.async_query(connection)
            for profile in all_profiles:
                if profile.name == "Primary":
                    await profile.async_make_default()
                    return

        iterm2.run_until_complete(main)
      '';
in
{
  home.file."/Library/Application Support/iTerm2/DynamicProfiles/PrimaryProfile.json".source = ./PrimaryProfile.json;
  home.file."/Library/Application Support/iTerm2/Scripts/AutoLaunch/set-default-profile.py".source = setDefaultProfile;
}

# The setDefaultProfile script is flaky at the moment, + requires manually enabling Python. I should revisit this.
