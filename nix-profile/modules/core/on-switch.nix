{ config, pkgs, lib, ... }:

with lib;

let
  switch-scripts = map
    (s: concatStrings [ "### " s.name " ###\n" s.script ])
    config.profile.onSwitch;
in {
  options = {
    profile.onSwitch = mkOption {
      type = with types; listOf (submodule {
        options = {
          name = mkOption {
            type = str;
            description = "Script name.";
          };
          script = mkOption {
            type = str;
            description = "Script text.";
          };
        };
      });
      default = [];
      defaultText = literalExample "[]";
      example = literalExample ''
        [
          {
            name = "Say Hello!";
            script = '''
              echo "Hello!"
            ''';
          }
        ]
      '';
      description = ''
        Set of scripts to run in switch-to-config.
      '';
    };
  };
  config = {
    profile.build.onSwitch = switch-scripts;
  };
}
